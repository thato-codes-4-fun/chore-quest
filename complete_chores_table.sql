-- Complete chores table recreation
-- Run this in your Supabase SQL editor

-- Drop existing table if it exists
DROP TABLE IF EXISTS public.chores CASCADE;

-- Create chores table with all required columns
CREATE TABLE public.chores (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    value DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    assignee_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    assigned_by_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'assigned' CHECK (status IN ('assigned', 'completed', 'approved', 'rejected')),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    approved_at TIMESTAMP WITH TIME ZONE,
    proof_image_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_chores_assignee_id ON public.chores(assignee_id);
CREATE INDEX idx_chores_assigned_by_id ON public.chores(assigned_by_id);
CREATE INDEX idx_chores_status ON public.chores(status);
CREATE INDEX idx_chores_created_at ON public.chores(created_at);

-- Enable Row Level Security
ALTER TABLE public.chores ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can view chores they're assigned to or assigned by them
CREATE POLICY "Users can view their own chores" ON public.chores
    FOR SELECT USING (
        auth.uid() = assignee_id OR 
        auth.uid() = assigned_by_id
    );

-- Parents can insert chores
CREATE POLICY "Parents can create chores" ON public.chores
    FOR INSERT WITH CHECK (
        auth.uid() = assigned_by_id
    );

-- Users can update chores they're involved with
CREATE POLICY "Users can update their own chores" ON public.chores
    FOR UPDATE USING (
        auth.uid() = assignee_id OR 
        auth.uid() = assigned_by_id
    );

-- Parents can delete chores they created
CREATE POLICY "Parents can delete their chores" ON public.chores
    FOR DELETE USING (
        auth.uid() = assigned_by_id
    );

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_chores_updated_at 
    BEFORE UPDATE ON public.chores 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Add comments for documentation
COMMENT ON TABLE public.chores IS 'Chores assigned to family members';
COMMENT ON COLUMN public.chores.id IS 'Unique identifier for the chore';
COMMENT ON COLUMN public.chores.name IS 'Name/title of the chore';
COMMENT ON COLUMN public.chores.description IS 'Detailed description of what needs to be done';
COMMENT ON COLUMN public.chores.value IS 'Points/Rands value for completing the chore';
COMMENT ON COLUMN public.chores.assignee_id IS 'ID of the kid assigned to do the chore';
COMMENT ON COLUMN public.chores.assigned_by_id IS 'ID of the parent who assigned the chore';
COMMENT ON COLUMN public.chores.status IS 'Current status: assigned, completed, approved, rejected';
COMMENT ON COLUMN public.chores.assigned_at IS 'Timestamp when the chore was assigned';
COMMENT ON COLUMN public.chores.completed_at IS 'Timestamp when the chore was completed by kid';
COMMENT ON COLUMN public.chores.approved_at IS 'Timestamp when the chore was approved by parent';
COMMENT ON COLUMN public.chores.proof_image_url IS 'URL to photo proof of completed chore';
COMMENT ON COLUMN public.chores.notes IS 'Additional notes from parent or kid';

-- Verify the table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'chores' 
AND table_schema = 'public'
ORDER BY ordinal_position;
