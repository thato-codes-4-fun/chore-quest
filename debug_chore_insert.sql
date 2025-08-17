-- Debug chore insert issue
-- Run this in your Supabase SQL editor

-- 1. Check current table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'chores' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Check current status constraint
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.chores'::regclass 
AND contype = 'c';

-- 3. Check what status values currently exist
SELECT DISTINCT status, COUNT(*) as count 
FROM public.chores 
GROUP BY status;

-- 4. Show the exact constraint definition
SELECT 
    tc.constraint_name,
    tc.constraint_type,
    cc.check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc 
    ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name = 'chores' 
AND tc.table_schema = 'public'
AND tc.constraint_type = 'CHECK';

-- 5. Test different status values
DO $$
DECLARE
    test_status TEXT;
    test_values TEXT[] := ARRAY['assigned', 'completed', 'approved', 'rejected', 'pending', 'done'];
BEGIN
    FOREACH test_status IN ARRAY test_values
    LOOP
        BEGIN
            INSERT INTO public.chores (
                id, name, description, value, 
                assigned_to, assigned_by, status,
                assigned_at, created_at, updated_at
            ) VALUES (
                gen_random_uuid()::text,
                'Test ' || test_status,
                'Test Description',
                10.0,
                'test_assignee',
                'test_assigner',
                test_status,
                NOW(),
                NOW(),
                NOW()
            );
            RAISE NOTICE 'Status "%" is VALID', test_status;
            
            -- Clean up
            DELETE FROM public.chores WHERE name = 'Test ' || test_status;
            
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Status "%" is INVALID: %', test_status, SQLERRM;
        END;
    END LOOP;
END $$;
