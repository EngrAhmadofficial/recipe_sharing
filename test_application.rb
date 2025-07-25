#!/usr/bin/env ruby

# Simple Application Test Script
# Run this to test basic functionality

puts "🧪 ARS Application Test Suite"
puts "=" * 50

# Test 1: Check if Rails server is running
puts "\n1. Testing Rails server..."
begin
  require 'net/http'
  uri = URI('http://localhost:3000')
  response = Net::HTTP.get_response(uri)
  if response.code == '200'
    puts "✅ Rails server is running"
  else
    puts "⚠️  Rails server responded with code: #{response.code}"
  end
rescue => e
  puts "❌ Rails server is not running: #{e.message}"
  puts "   Start the server with: rails server -p 3000"
  exit 1
end

# Test 2: Check database connection
puts "\n2. Testing database connection..."
begin
  require_relative 'config/environment'
  ActiveRecord::Base.connection.execute("SELECT 1")
  puts "✅ Database connection successful"
rescue => e
  puts "❌ Database connection failed: #{e.message}"
end

# Test 3: Check AI service configuration
puts "\n3. Testing AI service configuration..."
if ENV['OPENAI_API_KEY'].present?
  puts "✅ OpenAI API key is configured"
else
  puts "⚠️  OpenAI API key is not configured"
  puts "   Set OPENAI_API_KEY environment variable"
end

# Test 4: Check required gems
puts "\n4. Testing required gems..."
required_gems = ['http', 'json', 'rails']
required_gems.each do |gem_name|
  begin
    require gem_name
    puts "✅ #{gem_name} gem is available"
  rescue LoadError
    puts "❌ #{gem_name} gem is missing"
  end
end

puts "\n" + "=" * 50
puts "🎯 Manual Tests to Run:"
puts "1. Visit http://localhost:3000"
puts "2. Test user registration/login"
puts "3. Test AI meal planning feature"
puts "4. Test recipe creation and viewing"
puts "5. Test user preferences"
puts "6. Test navigation between pages"

puts "\n📋 Expected Application Flow:"
puts "1. User visits homepage"
puts "2. User registers/logs in"
puts "3. User can browse recipes"
puts "4. User can use AI features (meal planning, diet advice, etc.)"
puts "5. User can manage preferences"
puts "6. User can create meal plans and grocery lists"

puts "\n🚨 Common Issues to Check:"
puts "1. OpenAI API key configuration"
puts "2. Database migrations (run: rails db:migrate)"
puts "3. Asset compilation (run: rails assets:precompile)"
puts "4. JavaScript dependencies (check importmap)"
puts "5. Environment variables"

puts "\n✅ Test script completed!" 