-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    user_type TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS on users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view their own profile" 
ON public.users 
FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON public.users 
FOR UPDATE 
USING (auth.uid() = id);

-- Create child profiles table
CREATE TABLE IF NOT EXISTS public.child_profiles (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    age INTEGER NOT NULL,
    gender TEXT NOT NULL,
    ethnicity TEXT,
    family_history_of_autism BOOLEAN,
    jaundice_at_birth BOOLEAN,
    parent_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS on child_profiles table
ALTER TABLE public.child_profiles ENABLE ROW LEVEL SECURITY;

-- Child profiles table policies
CREATE POLICY "Users can view their own child profiles" 
ON public.child_profiles 
FOR SELECT 
USING (auth.uid() = parent_id);

CREATE POLICY "Users can insert their own child profiles" 
ON public.child_profiles 
FOR INSERT 
WITH CHECK (auth.uid() = parent_id);

CREATE POLICY "Users can update their own child profiles" 
ON public.child_profiles 
FOR UPDATE 
USING (auth.uid() = parent_id);

CREATE POLICY "Users can delete their own child profiles" 
ON public.child_profiles 
FOR DELETE 
USING (auth.uid() = parent_id);

-- Create assessments table
CREATE TABLE IF NOT EXISTS public.assessments (
    id UUID PRIMARY KEY,
    child_profile_id UUID NOT NULL REFERENCES public.child_profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE,
    scheduled_for TIMESTAMP WITH TIME ZONE,
    likelihood TEXT NOT NULL,
    quality_score INTEGER,
    video_path TEXT,
    questionnaire_responses JSONB,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS on assessments table
ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS assessments_child_profile_id_idx ON public.assessments (child_profile_id);

-- Assessments table policies
CREATE POLICY "Users can view their children's assessments" 
ON public.assessments 
FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.child_profiles
        WHERE child_profiles.id = assessments.child_profile_id
        AND child_profiles.parent_id = auth.uid()
    )
);

CREATE POLICY "Users can insert assessments for their children" 
ON public.assessments 
FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.child_profiles
        WHERE child_profiles.id = assessments.child_profile_id
        AND child_profiles.parent_id = auth.uid()
    )
);

CREATE POLICY "Users can update assessments for their children" 
ON public.assessments 
FOR UPDATE 
USING (
    EXISTS (
        SELECT 1 FROM public.child_profiles
        WHERE child_profiles.id = assessments.child_profile_id
        AND child_profiles.parent_id = auth.uid()
    )
);

CREATE POLICY "Users can delete assessments for their children" 
ON public.assessments 
FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM public.child_profiles
        WHERE child_profiles.id = assessments.child_profile_id
        AND child_profiles.parent_id = auth.uid()
    )
);

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_child_profiles_updated_at
BEFORE UPDATE ON public.child_profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_assessments_updated_at
BEFORE UPDATE ON public.assessments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column(); 