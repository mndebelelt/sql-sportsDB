/*
This script contains test commands to verify the functionality of the sportsDB.sql script. It includes commands to:

Check if tables are populated correctly.
Insert new members.
Delete members and handle pending terminations.
Update member information.
Test booking and payment functionalities.
Search for available rooms and make/cancel bookings.
Usage
Run the test.sql script after executing sportsDB.sql to ensure that all functionalities are working as expected.
*/

-- check if tables populated correctly
select * from members;
select * from pending_terminations;
select * from bookings;
select * from rooms;

-- insert new member
call insert_new_member('angelolott','1234abcd','AngeloNLott@gmail.com');

select * from members order by member_since desc;

-- delete little31 and afeil, little31 also has an outstanding balance 10
call delete_member('afeil');
call delete_member('little31');
select * from members;
select * from pending_terminations;

-- update member's password and email
call update_member_password ('noah51', '18Oct1976');
call update_member_email ('noah51', 'noah51@hotmail.com');
select * from members;


-- test update_payment
select * from members where id = 'marvin1';
select * from bookings where member_id = 'marvin1';

call update_payment (9);
select * from members where id = 'marvin1';
select * from bookings where member_id = 'marvin1';

-- search room 
call search_rooms('Archery Range', '2017-12-26', '13:00:00');

call search_rooms('Badminton Court', '2018-04-15', '14:00:00');

call search_rooms('Badminton Court', '2018-06-12', '15:00:00');

-- make a booking
call make_booking ('AR', '2017-12-26', '13:00:00', 'noah51');

call make_booking ('T1', curdate() + interval 2 week,
'11:00:00', 'noah51');
call make_booking ('AR', curdate() + interval 2 week,
'11:00:00', 'macejkovic73');
select * from bookings;

-- cancel booking
call cancel_booking(1, @message);
select @message;

select * from bookings;
call cancel_booking(12, @message);
select @message;

call cancel_booking(11, @message);
select @message;

