CREATE OR REPLACE FUNCTION registerUser(_user varchar(256), _pwd varchar(256), _isAdmin bool)
RETURNS varchar(256)
LANGUAGE plpgsql AS
    $$
    DECLARE res varchar(256);
        BEGIN
            INSERT INTO "User"."user"("userId", vc_username, vc_password, "b_isAdmin", "b_isAdult")
            VALUES (DEFAULT, _user, _pwd, _isAdmin, false) INTO res;
            RETURN res;
        END;
    $$;

