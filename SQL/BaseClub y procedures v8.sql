/* cspell:disable */
/* BASE DE DATOS */
drop database if exists Proyecto;
create database Proyecto;
use Proyecto;

create table roles(
RolUsu int,
NomRol varchar(30),
constraint primary key(RolUsu)
);

insert into roles values
(120,'Administrador'),
(121,'Empleado');

create table usuario(
CodUsu int auto_increment,
NombreUsu varchar (20),
PassUsu varchar (15),
RolUsu int,
Activo boolean default true,
constraint pk_usuario primary key (CodUsu),
constraint fk_usuario foreign key(RolUsu) references roles(RolUsu)
);

insert into usuario(CodUsu,NombreUsu,PassUsu,RolUsu) values
(1,'Admin','1234',120);

create table socio(
	NSocio int,
	Nombre varchar(40),
	DNI int,
	Correo varchar(40),
	FechaInscripcion date,
	AptoFisico boolean,
constraint pk_socio primary key(NSocio)
);

insert into socio values (1, "Fede H", 11222333, "fede@unmail.com", 20231024, true);

create table nosocio(
	NSocio int,
	Nombre varchar(40),
	DNI int,
	Correo varchar(40),
	FechaInscripcion date,
	AptoFisico boolean,
constraint pk_nosocio primary key(NSocio)
);

insert into nosocio values (1, "xxxxxx yyyyy", 4444444, "xxxx@unmail.com", 20231024, true);




drop table if exists cuotaSocio;

create table cuotaSocio(
IdCuota int NOT NULL AUTO_INCREMENT,
NSocio int,
Monto int,
FechaPago date,
MetodoPago int,
FechaInicio date,
Vencimiento date,
primary key(IdCuota),
foreign key(NSocio) REFERENCES socio(NSocio)
); 

insert into cuotaSocio values(0,1,300, 20231022, 1, 20231025, 20231125);

drop table if exists cuotaDiaria;

create table cuotaDiaria(
IdCuota int NOT NULL AUTO_INCREMENT,
NSocio int,
Monto int,
FechaPago date,
MetodoPago int,
FechaInicio date,
Vencimiento date,
primary key(IdCuota),
foreign key(NSocio) REFERENCES nosocio(NSocio)
); 

insert into cuotaDiaria values(0,1,400, 20231024, 1, 20231024, 20231124);



/* procedure Login */

delimiter //  
create procedure IngresoLogin(in Usu varchar(20),in Pass varchar(15))
begin
   select NomRol
	from usuario u inner join roles r on u.RolUsu = r.RolUsu
		where NombreUsu = Usu and PassUsu = Pass /* se compara con los parametros */
			and Activo = 1; /* el usuario debe estar activo */
end 
//

/* procedure NuevoSocio */

delimiter //

 create procedure NuevoSocio(
	in inNombre varchar(40),
	in inDNI int,
	in inCorreo varchar(40),
 	in inFechaInscripcion date,
	in inAptoFisico boolean,
	out rta int)
 
 begin
     declare filas int default 0;
	 declare existe int default 0;
     set filas = (select count(*) from socio);
     if filas = 0 then
		set filas = 1;  
     else
		set filas = (select max(NSocio) + 1 from socio);
	
		/*consulta para cuando checkiaba una sola de las dos tablas*/
		/*set existe = (select count(*) from socio where DNI = inDNI);*/

		/* consulta para checkiar tanto en socios como en no socios que no exista ese DNI*/
		set existe = (select count(*) from (select * from nosocio 
        where DNI = inDNI union select * from socio where DNI = inDNI) as S);
     end if;
	 
	  if existe = 0 then	 
		 insert into socio values(filas,inNombre,inDNI, inCorreo, inFechaInscripcion, inAptoFisico);
		 set rta  = filas;
	  else
		 set rta = existe;
      end if;		 
 end //

 /* procedure NuevoNoSocio */

delimiter //

 create procedure NuevoNoSocio(
	in inNombre varchar(40),
	in inDNI int,
	in inCorreo varchar(40),
 	in inFechaInscripcion date,
	in inAptoFisico boolean,
	out rta int)
 
 begin
     declare filas int default 0;
	 declare existe int default 0;
     set filas = (select count(*) from nosocio);
     if filas = 0 then
		set filas = 1;  
     else
		set filas = (select max(NSocio) + 1 from nosocio);

		/*consulta para cuando checkiaba una sola de las dos tablas*/
		/*set existe = (select count(*) from nosocio where DNI = inDNI);*/

		/* consulta para checkiar tanto en socios como en no socios que no exista ese DNI*/
		set existe = (select count(*) from (select * from nosocio 
        where DNI = inDNI union select * from socio where DNI = inDNI) as S);
     end if;
	 
	  if existe = 0 then	 
		 insert into nosocio values(filas,inNombre,inDNI, inCorreo, inFechaInscripcion, inAptoFisico);
		 set rta  = filas;
	  else
		 set rta = existe;
      end if;		 
 end //


 /* procedure NuevaCuota*/
 drop procedure if exists NuevaCuota;	

delimiter //

 create procedure NuevaCuota(
 	in inNSocio int,
	in inMonto int,
    in inFechaPago date,
    in inMetodoPago int,
	in inFechaInicio date,
	in inVencimiento date,
	out rta int)
 
 begin
 
     declare existe int default 0;
     set existe = (select NSocio from socio where socio.NSocio=inNSocio);

     if existe is null then
		set rta = 0; /* no existe el socio, mal puesto el dni */
     else
     	 insert into cuotaSocio values(0,inNSocio, inMonto, inFechaPago, inMetodoPago, inFechaInicio, inVencimiento);
		 set rta  = 1;
	 end if;		 
    
     end //

/* procedure NuevaCuotaDiaria*/
 drop procedure if exists NuevaCuotaDiaria;	

delimiter //

 create procedure NuevaCuotaDiaria(
 	in inNSocio int,
	in inMonto int,
    in inFechaPago date,
    in inMetodoPago int,
	in inFechaInicio date,
	in inVencimiento date,
	out rta int)
 
 begin
 
         declare existe int default 0;
 
       set existe = (select NSocio from nosocio where nosocio.NSocio=inNSocio);

     if existe is null then
		set rta = 0; /* no existe el socio, mal puesto el dni */
     else
     	 insert into cuotaDiaria values(0,inNSocio, inMonto, inFechaPago, inMetodoPago, inFechaInicio, inVencimiento);
		 set rta  = 1;
	 end if;		 
    
     end //
