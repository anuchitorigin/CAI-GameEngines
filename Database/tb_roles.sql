INSERT INTO roles
  (roleid, rolename, roleparam)
  VALUES 
  ('AUTH_SUPER','Super Admin',  '{"dashboard":1,"about":1,"lesson":1,"exam":1,"score":1,"system":1,"sys-var":1,"log-sys":1,"log-user":1,"sys-user":1,"__role-super":1}'),
  ('AUTH_ADMIN','Administrator','{"dashboard":1,"about":1,"lesson":1,"exam":1,"score":1,"system":1,"sys-var":1,"log-sys":1,"log-user":1,"sys-user":1,"__role-super":0}'),
  ('AUTH_OPER', 'Student',      '{"dashboard":1,"about":1,"lesson":1,"exam":1,"score":1,"system":0,"sys-var":0,"log-sys":0,"log-user":0,"sys-user":0,"__role-super":0}');
