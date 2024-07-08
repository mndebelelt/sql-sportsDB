/*
We are creating a databa se to manage the booking process of a sports complex. The sports 
complex has the following facilities: 2 tennis courts, 2 badminton courts, 2 multi-purpose
fields and 1 archery range.

Each facility can be booked for a duration of one hour.
 
Only registered users are allowed to make a booking. After booking, the
complex allows users to cancel their bookings latest by the day prior to the
booked date. Cancellation is free. However, if this is the third (or more)
consecutive cancellations, the complex imposes a $10 fine.

*/

#create database sports_booking;
#use sports_booking;

##################################################################################
-- create the tables 

create table members (
id varchar(255) primary key,
password varchar(255) not null, 
email varchar(255) not null,
member_since timestamp not null default now(),
payment_due decimal(10,2) not null default 0.00
);

create table pending_terminations(
id varchar(255) primary key,
email varchar(255) not null,
request_date timestamp default now() not null,
payment_due decimal(10,2) not null default 0.00
);

create table rooms (
id varchar(255) primary key,
room_type varchar(255) not null,
price decimal(10,2) not null
);

create table bookings (
id int primary key auto_increment,
room_id varchar(255) not null,
booked_date date not null,
booked_time time not null,
member_id varchar(255) not null,
datetime_of_booking timestamp not null default now(),
payment_status varchar(255) not null default 'Unpaid',
constraint uc1 unique (room_id, booked_date, booked_time),
constraint foreign key fk1 (member_id) references members(id) on update cascade on delete cascade,
constraint foreign key fk2 (room_id) references rooms(id) on update cascade on delete cascade
);

##################################################################################################
-- insert data 

insert into members (id, password, email, member_since, payment_due) values
('afeil', 'feil1988<3', 'Abdul.Feil@hotmail.com', '2017-04-15 12:10:13', 0),
('amely_18', 'loseweightin18', 'Amely.Bauch91@yahoo.com', '2018-02-06 16:48:43', 0),
('bbahringer', 'iambeau17', 'Beaulah_Bahringer@yahoo.com', '2017-12-28 05:36:50', 0),
('little31', 'whocares31', 'Anthony_Little31@gmail.com', '2017-06-01 21:12:11', 10),
('macejkovic73', 'jadajeda12', 'Jada.Macejkovic73@gmail.com', '2017-05-30 17:30:22', 0),
('marvin1', 'if0909mar', 'Marvin_Schulist@gmail.com', '2017-09-09 02:30:49', 10),
('nitzsche77', 'bret77@#', 'Bret_Nitzsche77@gmail.com', '2018-01-09 17:36:49', 0),
('noah51', '18Oct1976#51', 'Noah51@gmail.com', '2017-12-16 22:59:46', 0),
('oreillys', 'reallycool#1', 'Martine_OReilly@yahoo.com', '2017-10-12 05:39:20', 0),
('wyattgreat', 'wyatt111', 'Wyatt_Wisozk2@gmail.com', '2017-07-18 16:28:35', 0);

insert into rooms (id, room_type, price) values
('AR', 'Archery Range', 120),
('B1', 'Badminton Court', 8),
('B2', 'Badminton Court', 8),
('MPF1', 'Multi Purpose Field', 50),
('MPF2', 'Multi Purpose Field', 60),
('T1', 'Tennis Court', 10),
('T2', 'Tennis Court', 10);

insert into bookings (id, room_id, booked_date, booked_time, member_id, datetime_of_booking, payment_status) values
(1, 'AR', '2017-12-26', '13:00:00', 'oreillys', '2017-12-20 20:31:27', 'Paid'),
(2, 'MPF1', '2017-12-30', '17:00:00', 'noah51', '2017-12-22 05:22:10', 'Paid'),
(3, 'T2', '2017-12-31', '16:00:00', 'macejkovic73', '2017-12-28 18:14:23', 'Paid'),
(4, 'T1', '2018-03-05', '08:00:00', 'little31', '2018-02-22 20:19:17', 'Unpaid'),
(5, 'MPF2', '2018-03-02', '11:00:00', 'marvin1', '2018-03-01 16:13:45', 'Paid'),
(6, 'B1', '2018-03-28', '16:00:00', 'marvin1', '2018-03-23 22:46:36', 'Paid'),
(7, 'B1', '2018-04-15', '14:00:00', 'macejkovic73', '2018-04-12 22:23:20', 'Cancelled'),
(8, 'T2', '2018-04-23', '13:00:00', 'macejkovic73', '2018-04-19 10:49:00', 'Cancelled'),
(9, 'T1', '2018-05-25', '10:00:00', 'marvin1', '2018-05-21 11:20:46', 'Unpaid'),
(10, 'B2', '2018-06-12', '15:00:00', 'bbahringer', '2018-05-30 14:40:23', 'Paid');

#################################################################################################
 -- create a view that shows us all the booking details of a booking 
 
 create view member_bookings as 
 select bookings.id, room_id, room_type, booked_date, booked_time, member_id,
 datetime_of_booking, payment_status, price from bookings
 join rooms 
 on bookings.room_id = rooms.id
 order by bookings.id;
 
 ##############################################################################################
 -- PROCEDURES
 
 -- procedure to add new members 
 Delimiter $$ 
 create procedure insert_new_member (in p_id varchar(255), 
 in p_password varchar(255), in p_email varchar(255))
 begin
	insert into members (id, password, email) values (p_id, p_password, p_email);
end $$ 
 
 --  procedure to delete a member
create procedure delete_member (in p_id varchar(255))
begin
	delete from members where id = p_id;
end $$

-- procedure to update password 
create procedure update_member_password (in p_id varchar(255), in p_password varchar(255))
begin 
	update members
    set password = p_password 
    where id = p_id;
end $$

-- procedure to update email
create procedure update_member_email (in p_id varchar(255), in p_email varchar(255))
begin 
	update members
    set email = p_email 
    where id = p_id;
end $$

--  procedure to make a new booking
create procedure make_booking (in p_room_id varchar(255), in p_booked_date date, 
p_booked_time time, p_member_id varchar(255))
begin
	declare v_price decimal(10,2);
    declare v_payment_due decimal(10,2);
    
	select price into v_price from rooms where id = p_room_id;
    
    insert into bookings (room_id, booked_date, booked_time, member_id) values
    (p_room_id, p_booked_date, p_booked_time, p_member_id);
    
    select payment_due into v_payment_due from members where id = p_member_id;
    update members 
    set payment_due = v_payment_due + v_price
    where id = p_member_id;
    
end $$

-- procedure to update payment 
create procedure update_payment (in p_id int)
begin
	declare v_member_id varchar(255);
    declare v_payment_due decimal(10,2);
    declare v_price decimal(10,2);
    
    update bookings
    set payment_status = 'Paid'
    where id = p_id;
    
    select member_id, price into v_member_id, v_price
    from member_bookings where id = p_id;
    select payment_due into v_payment_due from members where id = v_member_id;
    
    update members 
    set payment_due = v_payment_due - v_price
    where id = v_member_id;
    
end $$

-- procedure to view all bookings for a member
create procedure view_bookings (in p_id varchar(255))
begin
	select * from member_bookings
    where id = p_id;
end $$

-- procedute to search for available rooms 
create procedure search_rooms (in p_room_type varchar(255), in p_booked_date date,in p_booked_time time)
begin
	select * from rooms where id not in (select room_id from bookings
where booked_date = p_booked_date AND booked_time = p_booked_time AND  payment_status != 'Cancelled') AND room_type = p_room_type;
end $$

-- cancel booking procedure 
create procedure cancel_booking (in p_booking_id int, out p_message varchar(255))
begin
	declare v_cancellation int;
    declare v_member_id varchar(255);
    declare v_payment_status varchar(255);
    declare v_booked_date date; 
    declare v_price decimal(10,2);
    declare v_payment_due decimal(10,2);
    
    set v_cancellation = 0;
    
    select member_id, booked_date, price, payment_status into v_member_id, v_booked_date, v_price, v_payment_status
    from member_bookings
    where id = p_booking_id;
    
    select payment_due into v_payment_due 
    from members
    where id = v_member_id;
    
    if curdate() >= v_booked_date then
		select 'Cancellation cannot be done on/after the booked date' into p_message;
	elseif v_payment_status = 'Cancelled' OR v_payment_status = 'Paid' then
		select 'Booking has already been cancelled or paid' into p_message;
	else
		update bookings 
        set payment_status = 'Cancelled'
        where id = p_booking_id;
        
        set v_payment_due = v_payment_due - v_price;
        
        set v_cancellation = check_cancellation(p_booking_id);
        
        if v_cancellation >= 2 then 
			set v_payment_due = v_payment_due + 10 ;
        end if;
        
		update members
        set payment_due = v_payment_due
        where id = v_member_id;
        
        select 'Booking Cancelled' into p_message;
    end if;
end $$
###################################################################################################################################
-- TRIGGERS 

-- trigger checks the outstanding balance of a member, which is recorded in the payment_due column
-- payment_due > 0 and member terminates account, we transfer data to pending_terminations
create trigger payment_check before delete on members for each row 
begin
	declare v_payment_due decimal(10,2);
    
SELECT 
    payment_due
INTO v_payment_due FROM
    members
WHERE
    id = OLD.id;
    
    if v_payment_due > 0 then
		insert into pending_terminations (id, email, payment_due)
        values (OLD.id, OLD.email, OLD.payment_due);
	end if;
end $$

####################################################################################################################################
-- STORED FUNCTION

-- function checks for the consecutive number of times the member has cancelled
create function check_cancellation (p_booking_id int) returns int deterministic
begin
	declare v_done int;
    declare v_cancellation int;
    declare v_current_payment_status varchar(255);
    
    declare cur cursor for
		select payment_status from bookings where member_id = (
			select member_id from bookings where id = p_booking_id) 
		order by datetime_of_booking desc;
    
    declare continue handler for not found set v_done = 1;
    
    set v_done = 1;
    set v_done = 0;
    
    open cur;
	cancellation_loop: loop
		fetch cur into v_current_payment_status;
        if v_current_payment_status != 'Cancelled' OR v_done = 1 then 
			leave cancellation_loop;
		else set v_cancellation = v_cancellation + 1; 
        end if;
	end loop;
    close cur;
    return v_cancellation;
end $$
delimiter ;