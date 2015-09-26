# BANKING APP

This is a simple banking app providing deposit, withdraw and transfer functions.

> **Usage**

>  In order to add a user via IRB: 

> - User.create(email: 'example@mail.com', password: '12345678', password_confirmation: '12345678')

Please be aware, you need to specify a 8 digits password that will be encryp by digest.


>  In order to credit an user account via IRB: 

> - User.deposit(value) e.g. User.deposit(50)

Be aware negative numbers are not allowed.


>  In order to make a transfer to another user account via IRB: 

> - User.transfer(otheruser_id, value) e.g. User.transfer(50, 11000.52)

Be aware negative numbers are not allowed.
