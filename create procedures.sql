use StandardDB
GO



create procedure check_password_condition
	@password varchar(255),
	@return bit output
	as
	begin
		-- Regular Expression to check if the password conditions letter more than 7 and less than 17, contains letters like($%&/(�)=?#@-.:!") and one letter and one number
		if (@password like '%[0-9]%' and @password like '%[A-Z]%' and  @password like '%[$%&/(�)=?#@-.:!"]%' and len(@password) >= 8 and len(@password)<=16)  --if password contans Letters and Numbers   
			set @return = 1
		else
			set @return = 0
	end
GO
/*
drop proc check_password_condition

declare @pass_check_result bit
exec check_password_condition 'zzzz%f', @pass_check_result output
print @pass_check_result
*/

create procedure check_contact_format
	@contact_type_id int,
	@contact varchar (255),
	@conName varchar(100) output,
	@return bit output
	as
	begin

		-- Declare temprary table to store the Contact types in one row to reduce time of query, need to know wiche type can verified
		declare @tempTable  table
		(
		  name varchar(100) null, 
		  type_verified bit  null
		);
		insert into @tempTable (name, type_verified) select name, type_verified from admins.contact_type where  admins.contact_type.id = @contact_type_id
		-- END Declare Temprary contact type Table

		-- check if this type can verified
		declare @contactVerified bit = (select type_verified from @tempTable );

		if (@contactVerified = 1) -- if this contact can verified insert contact
			begin
				-- get Contact Type Name
				declare @contactName varchar(100) = (select name from @tempTable ); 
				set @conName = @contactName

				-- check the Email or mobile format
				if((@contactName ='email' and @contact like '%___@___%.__%' ) or (@contactName ='mobile' and @contact not like '%[^0-9]%'))
					set @return = 1
				else
					set @return = 0
			end
	end
GO
/*
drop proc check_contact_format

declare @conn_check_result bit
declare @contactName varchar(100)
exec check_contact_format  '3', 'ahmad@test.com', @contactName output, @conn_check_result output
print @conn_check_result
print @contactName
*/



create procedure users.CreateNewUserAccount
	@username varchar(100),
	@password varchar(100),
------------------------------
	@contact_type_id int,
	@contact varchar (255)

as
begin
	
	-- check password format and condations
	declare @pass_check_result bit
	exec check_password_condition @password, @pass_check_result output
	if (@pass_check_result like 1)
		begin
			-- to stop System Comment
			set nocount on 

			-- check contacts format and condations
			declare @conn_check_result bit
			declare @contactName varchar(100)
			exec check_contact_format  @contact_type_id, @contact, @contactName output, @conn_check_result output

			if (@conn_check_result = 1) -- if this contact can verified insert contact and in right format
				begin
					-- Start insert new usesr with transaction
					begin transaction 

						-- Insert Username And Password
						insert into users.users (username)values(@username);

						-- after insert new user get User ID
						declare @userID uniqueidentifier = (select id from users.users where username like @username);

						-- Crate New Salt
						declare @salt uniqueidentifier=newid()

						-- insert Password after Hashing it and make concatenation with it and salt
						insert into users.password (user_id, password, salt)values(@userID, hashbytes('SHA2_512', @password+cast(@salt as nvarchar(36))), @salt);

						-- indert contact
						insert into users.contact (contact, user_id, contact_type_id)values(@contact,@userID , @contact_type_id );

						-- Rollback the transaction if there were any errors
						if (@@ERROR <> 0)
							begin
								-- Stop execute the transaction
								rollback

								-- Raise an error and return
								raiserror ('Add User Failed.', 16, 1)
								return
							end

						print 'Add User Successfully';
						commit-- Success the Updating
				end
				
			else-- this contact doesn't need to verify
				print 'User Need a contact can verified or the contact not in right format';
		end
	else
		print 'Password must has numbers and letters, and between 8 and 16 chars and Symbols like($%&/(�)=?#@-.:!")';
end
GO
--		DROP PROC users.CreateNewUserAccount

--0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

create procedure users.ActiveNewAccount
	@userID uniqueidentifier,
	@token uniqueidentifier
	as
	begin
	-- to stop System Comment
	set nocount on 

		declare @verified uniqueidentifier = (select id from users.users where id =  @userID and token = @token);
		if (@verified is not null)
			begin
				update users.users set acc_verified = 1 where id = @userID
				print 'verified successfully'
			end
		else
			print 'verified failed'
	end
GO
--		DROP PROC users.ActiveNewAccount

--0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

--CRAETE LOGIN PROCEDURE 
create procedure users.UserLogin
	-- 
	@username nvarchar(100),
    @password nvarchar(100)
	as
	begin
		-- to stop System Comment
		set nocount on 

		--Check if user has Acivate his Account
		declare @verified bit = (select acc_verified from users.users where username = @username)
		if(@verified is not null)
			begin
				if(@verified = 1)
					begin
						declare @userID uniqueidentifier = (select id from users.users where username = @username);
			
						declare @login uniqueidentifier = (select user_id from users.password where  user_id = @userID and password = hashbytes('SHA2_512', @password+cast(salt as nvarchar(36))) and default_pass =1);

						if(@login IS NULL)
							print 'Wrong Password'
						else
							begin
								print 'Successful Login'
								-- if user order to reset the password, then later he logged to his account with an old password before using the new token, set the new token as a used to avoid reset password
								update users.password set token_used = 1 where default_pass=1 and user_id = @userID
								-- with every login success set the date of this login
								update users.users set login_date = getdate() where id = @userID
							end
					end
				else
					print 'Please Active your Account '
			end
		else
			print 'this Account not Exist'
	end
GO
--	DROP PROC users.UserLogin


--0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000


create procedure users.OrderResetPassword
	@userID uniqueidentifier
	as
	begin
		-- to stop System Comment
		set nocount on 

		--check if the Account is Activated
		declare @tempUserTable table
		(
			username varchar(100),
			accVerified bit,
			passwordID uniqueidentifier,
			defaultPass bit,
			contact varchar(255),
			defaultCon bit,
			contactID uniqueidentifier,
			contactName varchar (100)
		)
		insert into @tempUserTable (username, accVerified, passwordID, defaultPass, contact,  defaultCon, contactID, contactName)
		select
			u.username,
			u.acc_verified,
			p.id,
			p.default_pass,
			c.contact,
			c.default_con,
			c.id,
			ct.name
		from users.users u
			join users.password p on u.id = p.user_id and p.default_pass = 1
			join users.contact c on u.id = c.user_id and c.default_con = 1
			join admins.contact_type ct on c.contact_type_id = ct.id
			where u.id = @userID

			if((select accVerified from @tempUserTable) = 1)
				begin
					select * from  @tempUserTable
					declare @randomeText varchar(255);
					if((select contactName from @tempUserTable) = 'email')
						begin
							set @randomeText = convert(varchar(255), newid());
							update users.password set token = @randomeText, token_used = 0 where user_id = @userID and default_pass = 1
						end
					else
						begin
						if((select contactName from @tempUserTable) = 'mobile')
							set @randomeText = (select substring(convert(varchar(40), newid()),0,9));
							update users.password set token = @randomeText, token_used = 0 where user_id = @userID and default_pass = 1
						end
				end
			else
				print 'Please Active this Account fierst'
		--begin TRANSACTION;  
		--DELETE from HumanResources.JobCandidate  
		--	where JobCandidateID = 13;  
		--COMMIT;  

	end
GO
--		DROP PROC users.OrderResetPassword



create procedure users.ActionResetPassword
	@userID uniqueidentifier,
	@token varchar(255),
	@password varchar(100)

	as
	begin
		-- to stop System Comment
		set nocount on 

		--check if this tomen used before
		declare @tokenIsUsed bit = (select token_used 
									from users.password 
									where user_id = @userID and token = @token )
		if(@tokenIsUsed = 0)
			begin
				--Chech if this new Password existing before
				declare @oldPasswords table
				(
					password_ BINARY(64),
					salt_ uniqueidentifier
				)
				insert into @oldPasswords select password, salt from users.password where user_id = @userID

				declare @passwordExisting  binary(64) = (select  password_ from  @oldPasswords where password_ =  hashbytes('SHA2_512', @password+cast(salt_ as nvarchar(36))));

				if(@passwordExisting IS NULL)
					begin

						begin transaction 
							update users.password set token_used = 1, default_pass = 0 where user_id = @userID ;
					
							declare @newSalt uniqueidentifier = newid();
							insert into users.password  (user_id, password, salt)values
							(
								@userID,
								hashbytes('SHA2_512', @password+cast(@newSalt as nvarchar(36))),
								@newSalt
							)
							-- Rollback the transaction if there were any errors
							if (@@ERROR <> 0)
								begin
									-- Stop execute the transaction
									rollback

									-- Raise an error and return
									raiserror ('Error in Updating Token result.', 16, 1)
									return
								end
							print 'update password successfully.'
							commit-- Success the Updating
					end
				else
					print 'this password existing before'
			end
		else
			print  'This link has expired';
	end
GO
--  DROP PROC users.ActionResetPassword




create trigger users.delete_user
	on users.users
	instead of delete
	as
	begin
		-- to stop System Comment
		set nocount on;
		begin
			-- start delete 

			-- delete in blocked table
			delete from users.blocked where  user_id in (select id from deleted)
			delete from users.blocked where  blocked_id in (select id from deleted)
			-- delete in followed table
			delete from users.followed where  user_id in (select id from deleted)
			delete from users.followed where  followed_id in (select id from deleted)
			-- delete in password table
			delete from users.password where  user_id in (select id from deleted)
			-- delete in address table
			delete from users.address where  user_id in (select id from deleted)
			-- delete in device table
			delete from users.device where  user_id in (select id from deleted)
			-- delete in contact table
			delete from users.contact where user_id in (select id from deleted)
			-- delete in comment table
			delete from users.comment where user_id in (select id from deleted)
			-- delete in like_comment table
			delete from users.like_comment where user_id in (select id from deleted)
			-- delete in like_post table
			delete from users.like_recipe where user_id in (select id from deleted)

			-- delete in post table,
			-- if some users clone a post author = users.users(id) 

			-- check if there in post table author_id and user_id not the same, if there, that mean someone has been this post cloned


			-- delete in post_upload table

			-- delete in upload table

			delete from users.users where id in (select id from deleted)





			-- Rollback the transaction if there were any errors
			if (@@ERROR <> 0)
				begin
					-- Stop execute the transaction
					rollback
					-- Raise an error and return
					raiserror ('Error in Updating Token result.', 16, 1)
					return
				end
		end
	end
GO
--		drop trigger users.delete_user




