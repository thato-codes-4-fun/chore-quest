-- Fix chores status constraint
-- Run this in your Supabase SQL editor

-- First, let's see what the current constraint looks like
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.chores'::regclass 
AND contype = 'c';

-- Check what status values currently exist in the table
SELECT DISTINCT status FROM public.chores;

-- Drop the existing constraint if it exists
ALTER TABLE public.chores DROP CONSTRAINT IF EXISTS chores_status_check;

-- Add the correct constraint that matches our enum values
ALTER TABLE public.chores 
ADD CONSTRAINT chores_status_check 
CHECK (status IN ('assigned', 'completed', 'approved', 'rejected'));

-- Verify the constraint was added correctly
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.chores'::regclass 
AND contype = 'c';

-- Test insert to make sure it works
DO $$
BEGIN
    BEGIN
        INSERT INTO public.chores (
            id, name, description, value, 
            assigned_to, assigned_by, status,
            assigned_at, created_at, updated_at
        ) VALUES (
            gen_random_uuid()::text,
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
        RAISE NOTICE 'Test insert successful - status constraint is working';
        
        -- Clean up test data
        DELETE FROM public.chores WHERE name = 'Test Chore';
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error during test insert: %', SQLERRM;
    END;
END $$;
