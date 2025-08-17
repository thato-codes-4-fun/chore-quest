-- Refresh schema cache and verify chores table structure
-- Run this in your Supabase SQL editor

-- First, let's verify the current table structure
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

-- Check if all required columns exist
DO $$
DECLARE
    missing_columns TEXT[] := ARRAY[]::TEXT[];
    required_columns TEXT[] := ARRAY[
        'id', 'name', 'description', 'value', 
        'assignee_id', 'assigned_by_id', 'status',
        'assigned_at', 'completed_at', 'approved_at',
        'proof_image_url', 'notes', 'created_at', 'updated_at'
    ];
    col TEXT;
BEGIN
    -- Check for missing columns
    FOREACH col IN ARRAY required_columns
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'chores' 
            AND table_schema = 'public' 
            AND column_name = col
        ) THEN
            missing_columns := array_append(missing_columns, col);
        END IF;
    END LOOP;
    
    -- Report missing columns
    IF array_length(missing_columns, 1) > 0 THEN
        RAISE NOTICE 'Missing columns: %', array_to_string(missing_columns, ', ');
    ELSE
        RAISE NOTICE 'All required columns exist!';
    END IF;
END $$;

-- Force refresh of the schema cache by doing a dummy operation
-- This sometimes helps Supabase recognize new columns
SELECT pg_notify('schema_refresh', 'chores_table_updated');

-- Alternative: Try to access each column to force cache refresh
SELECT 
    id, name, description, value,
    assignee_id, assigned_by_id, status,
    assigned_at, completed_at, approved_at,
    proof_image_url, notes, created_at, updated_at
FROM public.chores 
LIMIT 1;

-- If the above fails, let's add any missing columns
DO $$
BEGIN
    -- Add assigned_by_id if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'chores' 
        AND table_schema = 'public' 
        AND column_name = 'assigned_by_id'
    ) THEN
        ALTER TABLE public.chores ADD COLUMN assigned_by_id TEXT;
        RAISE NOTICE 'Added assigned_by_id column';
    END IF;
    
    -- Add other potentially missing columns
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'chores' 
        AND table_schema = 'public' 
        AND column_name = 'assignee_id'
    ) THEN
        ALTER TABLE public.chores ADD COLUMN assignee_id TEXT;
        RAISE NOTICE 'Added assignee_id column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'chores' 
        AND table_schema = 'public' 
        AND column_name = 'assigned_at'
    ) THEN
        ALTER TABLE public.chores ADD COLUMN assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added assigned_at column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'chores' 
        AND table_schema = 'public' 
        AND column_name = 'completed_at'
    ) THEN
        ALTER TABLE public.chores ADD COLUMN completed_at TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Added completed_at column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'chores' 
        AND table_schema = 'public' 
        AND column_name = 'approved_at'
    ) THEN
        ALTER TABLE public.chores ADD COLUMN approved_at TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Added approved_at column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'chores' 
        AND table_schema = 'public' 
        AND column_name = 'proof_image_url'
    ) THEN
        ALTER TABLE public.chores ADD COLUMN proof_image_url TEXT;
        RAISE NOTICE 'Added proof_image_url column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'chores' 
        AND table_schema = 'public' 
        AND column_name = 'notes'
    ) THEN
        ALTER TABLE public.chores ADD COLUMN notes TEXT;
        RAISE NOTICE 'Added notes column';
    END IF;
END $$;

-- Final verification
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'chores' 
AND table_schema = 'public'
ORDER BY ordinal_position;
