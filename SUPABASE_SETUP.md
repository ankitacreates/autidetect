# Supabase Setup Guide for AutiDetect

This guide explains how to set up Supabase as a database for AutiDetect app.

## Prerequisites

1. Create a Supabase account at [https://supabase.com](https://supabase.com)
2. Create a new Supabase project

## Database Setup

1. Go to the SQL Editor in your Supabase dashboard
2. Copy the SQL from `supabase_schema.sql` in this repository
3. Execute the SQL to create all required tables and policies

## Environment Configuration

1. Copy `.env.example` to `.env` in your project root
2. Update the `.env` file with your Supabase URL and anon key:
   ```
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```
3. You can find these values in your Supabase project settings under API

## Authentication Setup

Supabase handles user authentication with the following features:
- Email/password authentication
- Email verification
- Password reset

### Configuration Steps:

1. Go to Authentication > Settings in your Supabase dashboard
2. Enable Email provider
3. Configure Site URL to your app's URL
4. Set up redirect URLs for authentication flows:
   - For development: `http://localhost:3000/**`
   - For production: `https://yourapp.com/**`

## Storage Setup

If you plan to store files (like assessment videos):

1. Go to Storage in your Supabase dashboard
2. Create a new bucket called `assessment-videos`
3. Set the bucket accessibility to private
4. Update bucket policies to allow authenticated users to upload/download their videos

## Row Level Security (RLS)

The SQL schema includes Row Level Security policies to ensure:
- Users can only access their own data
- Users can only see child profiles they created
- Users can only see assessments for their children

## App Integration

1. Make sure to add `supabase_flutter` package to your `pubspec.yaml`
2. Initialize Supabase in your app as shown in `main.dart`
3. Use the `SupabaseService` class for all database operations

## Troubleshooting

If you encounter issues:
1. Check your `.env` file has the correct credentials
2. Ensure Supabase is properly initialized before using it
3. Check the console for error messages
4. Verify that RLS policies are correctly set up for your tables 