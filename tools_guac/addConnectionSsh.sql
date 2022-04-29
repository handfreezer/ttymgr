delimiter //
create or replace procedure addConnectionSsh(in cnx_name varchar(100), in cnx_ip varchar(30), in reader varchar(100), out cnx_id int)
begin
	declare exit handler for SQLEXCEPTION
	begin
		show errors;
		rollback;
	end;

	start transaction;
		insert into guacamole_connection (connection_name, protocol) values (cnx_name, 'ssh');
		select connection_id into cnx_id from guacamole_connection where connection_name = cnx_name and parent_id is NULL;
		insert into guacamole_connection_parameter values (cnx_id, 'hostname', cnx_ip);
		insert into guacamole_connection_parameter values (cnx_id, 'port' , '22');
		select entity_id into @gr_id from guacamole_entity where name = reader;
		insert into guacamole_connection_permission values (@gr_id, cnx_id, 'READ');
	commit;
end
//
delimiter ;
