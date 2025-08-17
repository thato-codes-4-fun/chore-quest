-- Diagnostic script for chores table issues
-- Run this in your Supabase SQL editor

-- 1. Check if the table exists
SELECT 
    table_name, 
    table_type 
FROM information_schema.tables 
WHERE table_name = 'chores' 
AND table_schema = 'public';

-- 2. List all columns in the table
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default,
    ordinal_position
FROM information_schema.columns 
WHERE table_name = 'chores' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Check for any data in the table
SELECT COUNT(*) as total_rows FROM public.chores;

-- 4. Try to insert a test record to see the exact error
-- (This will help identify which column is causing the issue)
DO $$
BEGIN
    BEGIN
        INSERT INTO public.chores (
            id, name, description, value, 
            assignee_id, assigned_by_id, status,
            assigned_at, created_at, updated_at
        ) VALUES (
            'test_' || extract(epoch from now())::text,
            'Test Chore',
            'Test Description',
            10.0,
            'test_assignee',
            'test_assigner',
            'assigned',
            NOW(),
            NOW(),
            NOW()
        );
        RAISE NOTICE 'Test insert successful - all columns exist';
        
        -- Clean up test data
        DELETE FROM public.chores WHERE id LIKE 'test_%';
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error during test insert: %', SQLERRM;
    END;
END $$;

-- 5. Check RLS policies
SELECT 
    policyname, 
    permissive, 
    roles, 
    cmd, 
    qual, 
    with_check
FROM pg_policies 
WHERE tablename = 'chores' 
AND schemaname = 'public';

-- 6. Check table permissions
SELECT 
    grantee, 
    privilege_type, 
    is_grantable
FROM information_schema.role_table_grants 
WHERE table_name = 'chores' 
AND table_schema = 'public';
