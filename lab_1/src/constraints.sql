alter table mservice.account
	add constraint unique_log_user primary key (login),
	alter column password set not null,
	alter column name set not null,
	alter column surname set not null,
    add constraint correct_email check (mail ~ '^[\w\-\.]+@([\w\-]+\.)+[\w\-]+$');

alter table mservice.musician
	add constraint unique_log_mus primary key (login),
	add constraint pos_followers check (followers >= 0),
	alter column name set not null,
	alter column surname set not null;
	
alter table mservice.producer
	add constraint unique_log_prod primary key (login),
	add constraint pos_followers check (followers >= 0),
	alter column name set not null,
	alter column surname set not null;
	
alter table mservice.track
	add constraint unique_id primary key (id),
	add constraint pos_listenings check (count_listening >= 0),
	add constraint pos_duration check (duration >= 0),
	add constraint pos_year_of_issue check (year_of_issue >= 2000);
	
alter table mservice.mus_prod
	add constraint mus_id foreign key (id_mus) references musician (login),
	add constraint prod_id foreign key (id_prod) references producer (login),
	alter column id_mus set not null,
	alter column id_prod set not null;

alter table mservice.mus_track
	add constraint mus_id foreign key (id_mus) references musician (login),
	add constraint track_id foreign key (id_track) references track (id),
	alter column id_mus set not null,
	alter column id_track set not null;

alter table mservice.user_mus
	add constraint mus_id foreign key (id_mus) references musician (login),
	add constraint user_id foreign key (id_user) references account (login),
	alter column id_mus set not null,
	alter column id_user set not null;

alter table mservice.user_track
	add constraint user_id foreign key (id_user) references account (login),
	add constraint track_id foreign key (id_track) references track (id),
	alter column id_track set not null,
	alter column id_user set not null;

alter table mservice.prod_track
	add constraint prod_id foreign key (id_prod) references producer (login),
	add constraint track_id foreign key (id_track) references track (id),
	alter column id_prod set not null,
	alter column id_track set not null;
