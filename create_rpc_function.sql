-- Create RPC function to bypass RLS for user creation
-- Run this in your Supabase SQL Editor

-- Create the RPC function
CREATE OR REPLACE FUNCTION create_user_profile(
    user_id UUID,
    user_name TEXT,
    user_email TEXT,
    user_role TEXT,
    parent_id UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Insert the user profile
    INSERT INTO public.users (
        id,
        name,
        email,
        role,
        parent_id,
        balance,
        created_at,
        updated_at
    ) VALUES (
        user_id,
        user_name,
        user_email,
        user_role,
        parent_id,
        0.00,
        NOW(),
        NOW()
    );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_user_profile(UUID, TEXT, TEXT, TEXT, UUID) TO authenticated;

-- Test the function (optional - you can run this to test)
-- SELECT create_user_profile(
--     'test-user-id'::UUID,
--     'Test User',
--     'test@example.com',
--     'parent',
--     NULL
-- );
