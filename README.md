# FMCSA_NEW_SAFER
SAFER Re architecture for OY3 

Some Notes 

C:\oraclexe\app\oracle\product\11.2.0\server\network\ADMIN\tnsnames.ora

create user FMCSA/FMCSA

GRANT CONNECT TO FMCSA;
GRANT CONNECT, RESOURCE, DBA TO FMCSA;
GRANT CREATE SESSION  TO FMCSA;
GRANT SELECT, INSERT, UPDATE, DELETE TO FMCSA;

CREATE TABLE "FMCSA"."SAFER_XML_TRANSACTION" 
   (	"TRANSACTION_ID" NUMBER, 
	"TRANSACTION_CODE" VARCHAR2(20 BYTE), 
	"DEFINITION_SQL_STATEMENT" VARCHAR2(1000 BYTE)
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  ;
  

Insert into FMCSA.SAFER_XML_TRANSACTION (TRANSACTION_ID,TRANSACTION_CODE,DEFINITION_SQL_STATEMENT) values (1,'T0024','BCDA');
Insert into FMCSA.SAFER_XML_TRANSACTION (TRANSACTION_ID,TRANSACTION_CODE,DEFINITION_SQL_STATEMENT) values (2,'T0024','NNNN');


2. Git commands 
Git repository 
https://github.com/indranil328/FMCSA_NEW_SAFER

-- See trace 
SET GIT_TRACE=1
SET GCM_TRACE=1

-- remove trace 
SET GIT_TRACE=0
SET GCM_TRACE=0

git config --list

git config --list --show-origin

--- In order to add the ssh key 
ssh-keygen -t rsa -b 4096 -C "indranil328@gmail.com"
passphrase : FMCSA

ssh key is in 
C:\Users\pali\.ssh

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOnkWoCB8X8f+iitUc20RPivF5Zuto4RbI242eXPc9dV2aaBqSqnNSwMXAU331LRiMM1j91AHehA8tMyakQWvguDJL6LsuvBnq6zTIN3hz6xo+bgBwAsa3ZPb+o9H5CDXe2vT3AqR/BEM2T7g9+SqS1uYJEueQ2MECTMlM2legCgFUIE+ALhNRoFOfjn1Z9nGTQXx7yXisCvuoNZ7NfJFwi6tcgailb+TGOsgkGKd+J26v9l2/zhTnYFagHmjw9qV2PvlhOKNqpJvNgdlMj6ucwgvKqgu2PpY9JJkncjpTaGPWqOoImd8v9YTAc6dbBfWo638hF6/u3zaYcs//Az62HHMCWMvDdeOU90fylQj7hBXWdCZdz4zQbvyKHzVmnaX3K3HUwQsRJBtZwfhsPDvPIL4S+f/nT7Fl637DV9Owk52TT/4qFGfOzV9aSASIHiS3whefgAB+nhb1b9sah1YtlohTqJdweWcbBa7pjoZK9c4afwJi87LvnzB42AAEpVuuiT0lCrOoQJgv0jOIsun+YTwSDnqs6YK8LD93K3or0sy77U9wTx6XuczWCTNJxma4jb8/wUzoeEiit42RgjAMNbHOsxjjcWsNZsT+DXZpkpxbqwtSBSmXeMfM3CTPpsIN/+wmCDVsljorWGk0x7hGlNwECq7hisbN6ireKxzkNQ== indranil328@gmail.com

go to 
git add .
git commit -m <Comment>
git push 

git remote show origin
to avoid user id and password in git push
git remote set-url origin git+ssh://git@github.com/indranil328/FMCSA_NEW_SAFER.git

to avoid passphrase in git push
Enter passphrase for key '/c/Users/pali/.ssh/id_rsa':

Open git bash 
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa








