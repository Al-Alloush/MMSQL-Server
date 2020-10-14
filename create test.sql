use StandardDB

delete from  users.Users;

/*
CreateNewUserAccount
	@username varchar(100), 
	@password varchar(16), 
	@contactType_id int,  --(1=email(1),2=mobile(1),3=website(0))
	@contact varchar (255)

*/

print ''
print '----------------------------------------------------------------- Password smaller than 8 or Bigger than 16 , has numbers and letters and spatial symbls'
exec users.CreateNewUserAccount 'Jack','kufkasfgadsf',1,'test@email.com'--------------------------- Password must has numbers and letters and spatial symbls, between 8 and 16 Characters
exec users.CreateNewUserAccount 'Jack','4583534585',1,'test@email.com'----------------------------- Password must has numbers and letters and spatial symbls, between 8 and 16 Characters
exec users.CreateNewUserAccount 'Jack','dd&dsd%dvgg',1,'test@email.com'---------------------------- Password must has numbers and letters and spatial symbls, between 8 and 16 Characters
exec users.CreateNewUserAccount 'Jack','458%3&345?85',1,'test@email.com'--------------------------- Password must has numbers and letters and spatial symbls, between 8 and 16 Characters

exec users.CreateNewUserAccount 'Jack','!fg&bfff9473',1,'test@email.com'------------------- The user has been successfully added
declare @acc_verified_Jack uniqueidentifier = (select token from users.users where username = 'Jack')
declare @JackID uniqueidentifier = (select id from users.users where username = 'Jack')
exec users.ActiveNewAccount @JackID , @acc_verified_Jack



print ''
print '----------------------------------------------------------------- Test Email Contacts Form'
exec users.CreateNewUserAccount 'Neck','$%dasRRic86',1,'testtest.de' ------------ It is in email Form
exec users.CreateNewUserAccount 'Neck','$%dasRRic86',1,'test@test' -------------- It is in email Form
exec users.CreateNewUserAccount 'Neck','$%dasRRic86',1,'test@test.' ------------- It is in email Form
exec users.CreateNewUserAccount 'Neck','$%dasRRic86',1,'test@test.d' ------------ It is in email Form
exec users.CreateNewUserAccount 'Neck','$%dasRRic86',1,'t@test.d' --------------- It is in email Form
exec users.CreateNewUserAccount 'Neck','$%dasRRic86',1,'test@t.d' --------------- It is in email Form

exec users.CreateNewUserAccount 'Neck','$%dasRRic86',1,'test@test.de' ------- The user has been successfully added
declare @acc_verified_Neck uniqueidentifier = (select token from users.users where username = 'Neck')
declare @NeckID uniqueidentifier = (select id from users.users where username = 'Neck')
exec users.ActiveNewAccount @NeckID , @acc_verified_Neck 

print ''
print '----------------------------------------------------------------- Test Mobile Contacts Form'
exec users.CreateNewUserAccount 'John','&hdhdhhs2005',2,'fgfghfghfgh' ------------------ It is NOT in mobile Forms
exec users.CreateNewUserAccount 'John','&hdhdhhs2005',2,'(+49) 535353234' -------------- It is NOT in mobile Forms
exec users.CreateNewUserAccount 'John','&hdhdhhs2005',2,'0831-62622572'----------------- It is NOT in mobile Forms
exec users.CreateNewUserAccount 'John','&hdhdhhs2005',2,'17345a676533'------------------ It is NOT in mobile Forms
exec users.CreateNewUserAccount 'John','&hdhdhhs2005',2,'17345676533'------------------- The user has been successfully added
-- this Accoint not activated 

print '-----------------------------------------------------------------'

exec users.CreateNewUserAccount 'Mary','&fhfhAtz45',4,'17345676533'
declare @acc_verified_Mary uniqueidentifier = (select token from users.users where username = 'Mary')
declare @MaryID uniqueidentifier = (select id from users.users where username = 'Mary')
exec users.ActiveNewAccount @MaryID , @acc_verified_Mary

exec users.CreateNewUserAccount 'Sam','&hdhdhhs2005',1,'allou@gmail.com'
declare @acc_verified_Sam uniqueidentifier = (select token from users.users where username = 'Sam')
declare @SamID uniqueidentifier = (select id from users.users where username = 'Sam')
exec users.ActiveNewAccount @SamID , @acc_verified_Sam

exec users.CreateNewUserAccount 'Reinhold','&hdhdhhs2005',1,'aaaaaallou@gmail.com'
declare @acc_verified_Reinhold uniqueidentifier = (select token from users.users where username = 'Reinhold')
declare @ReinholdID uniqueidentifier = (select id from users.users where username = 'Reinhold')
exec users.ActiveNewAccount @ReinholdID , @acc_verified_Reinhold

exec users.CreateNewUserAccount 'Senta','&hdhdhhs2005',2,'1734666666'
declare @acc_verified_Senta uniqueidentifier = (select token from users.users where username = 'Senta')
declare @RSentaID uniqueidentifier = (select id from users.users where username = 'Senta')
exec users.ActiveNewAccount @RSentaID , @acc_verified_Senta


/*
users.UserLogin
	@username nvarchar(100), 
	@password nvarchar(100)

success Login ( 'Jack','!fg&bfff9473' ), ( 'Neck','$%dasRRic86' ), ( 'Mary','&fhfhAtz45' ), ( 'Sam','&hdhdhhs2005' )
not Active (  'John','&hdhdhhs2005' )
not Exist ( 'ahmad', 'zzt%323dddf' )
*/
exec users.UserLogin 'Neck','$%dasRRic86' 
exec users.UserLogin 'Jack','!fg&bfff9473--new'
exec users.UserLogin 'John', '&hdhdhhs2005'
exec users.UserLogin 'ahmad', 'zzt%323dddf'

/*
users.OrderResetPassword
	@user_id uniqueidentifier)

users.ActionResetPassword
	@userID uniqueidentifier,
	@token varchar(255),
	@password varchar(255)

-- Jack 
*/


declare @jackID_2 uniqueidentifier = (select id from users.users where username like 'Jack'); 
-------------
exec users.OrderResetPassword @jackID_2
----------------
declare @jackToken varchar(255) = (select token from users.password where user_id like @jackID_2 and default_pass = 1 and token_used=0)
--------------------
exec users.ActionResetPassword   @jackID_2, -- @user_id uniqueidentifier
								 @jackToken, -- @token varchar(255)
								 '!fg&bfff9473'  -- @password varchar(100)

exec users.ActionResetPassword   @jackID_2, -- @user_id uniqueidentifier
								 @jackToken, -- @token varchar(255)
								 '!fg&bfff9473--new3'  -- @password varchar(100)

exec users.UserLogin 'Jack','!fg&bfff9473'
exec users.UserLogin 'Jack','!fg&bfff9473--new3'
