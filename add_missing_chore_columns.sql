-- Add missing columns to chores table
-- Run this in your Supabase SQL editor

-- Add approved_at column
ALTER TABLE public.chores 
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;

-- Add completed_at column (if not already exists)
ALTER TABLE public.chores 
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;

-- Add assigned_at column (if not already exists)
ALTER TABLE public.chores 
ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Add proof_image_url column (if not already exists)
ALTER TABLE public.chores 
ADD COLUMN IF NOT EXISTS proof_image_url TEXT;

-- Add notes column (if not already exists)
ALTER TABLE public.chores 
ADD COLUMN IF NOT EXISTS notes TEXT;

-- Update existing records to have assigned_at if it's null
UPDATE public.chores 
SET assigned_at = created_at 
WHERE assigned_at IS NULL;

-- Add comments for documentation
COMMENT ON COLUMN public.chores.approved_at IS 'Timestamp when the chore was approved by parent';
COMMENT ON COLUMN public.chores.completed_at IS 'Timestamp when the chore was completed by kid';
COMMENT ON COLUMN public.chores.assigned_at IS 'Timestamp when the chore was assigned';
COMMENT ON COLUMN public.chores.proof_image_url IS 'URL to photo proof of completed chore';
COMMENT ON COLUMN public.chores.notes IS 'Additional notes from parent or kid';

-- Verify the table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'chores' 
AND table_schema = 'public'
ORDER BY ordinal_position;
