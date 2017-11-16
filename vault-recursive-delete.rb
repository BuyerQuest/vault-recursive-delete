#!/opt/chefdk/embedded/bin/ruby
# rubocop:disable Metrics/LineLength,Metrics/MethodLength,Metrics/AbcSize

require 'yaml'
require 'vault'
require 'optparse'

APP_TITLE = 'Vault recursive delete'.freeze
SCRIPT_NAME = __FILE__.freeze
VERSION = '1.0.0'.freeze

options = {}
parser = OptionParser.new do |opts|
  opts.banner = "Recursive delete for paths in vault.\n\nUsage: #{SCRIPT_NAME} [options]"

  opts.on('-a[VAULT_ADDR]', '--vault-address=[VAULT_ADDR]', 'URL used to access the Vault server. Defaults to the VAULT_ADDR environment variable if not set') do |v|
    options[:vault_addr] = v
  end

  opts.on('-pPATH', '--path=PATH', 'Path in vault to delete from, with a trailing slash. E.g. secret/foo/') do |v|
    options[:path] = v
  end

  opts.on('--force', 'Suppress confirmation and delete automatically. Use carefully.') do |v|
    options[:force] = v
  end

  opts.separator('')
  opts.on('-h', '--help', 'Display this help') do
    puts opts
    exit
  end

  opts.on('-v', '--version', 'Display the current script version') do
    puts "#{APP_TITLE} - version #{VERSION}"
    exit
  end
end
parser.parse!

# Check for a path
raise OptionParser::MissingArgument, 'PATH is required. Try the --help argument.' if options[:path].nil?

vault_url = options[:vault_addr].nil? ? ENV['VAULT_ADDR'] : options[:vault_addr]

# Check that we have something for the vault URL
raise OptionParser::MissingArgument, 'Vault Address is required' if vault_url.nil?

# Uncover the full path of every subkey under a given vault key
def get_vault_paths(keys = 'secret/')
  # We need to work with an array
  if keys.is_a?(String)
    keys = [keys]
  else
    raise ArgumentError, 'The supplied path must be a string or an array of strings.' unless keys.is_a?(Array)
  end

  # the first element should have a slash on the end, otherwise
  # this function is likely being called improperly
  keys.each do |key|
    raise ArgumentError, "The supplied path #{key} should end in a slash." unless key[-1] == '/'
  end

  # go through each key and add all sub-keys to the array
  keys.each do |key|
    Vault.logical.list(key).each do |subkey|
      # if the key has a slash on the end, we must go deeper
      keys.push("#{key}#{subkey}") if subkey[-1] == '/'
    end
  end

  # Remove duplicates (probably unnecessary), and sort
  keys.uniq.sort
end

# Find all of the secrets sitting under an array of vault paths
def get_vault_secrets(vault_paths)
  if vault_paths.is_a?(String)
    vault_paths = [vault_paths]
  else
    raise ArgumentError, 'The supplied path must be a string or an array of strings.' unless vault_paths.is_a?(Array)
  end

  vault_secrets = []

  vault_paths.each do |key|
    Vault.logical.list(key).each do |secret|
      vault_secrets.push("#{key}#{secret}") unless secret[-1] == '/'
    end
  end

  # return a sorted array
  vault_secrets.sort
end

# Actually delete the stuff
def vault_recursive_delete(del_path, force_delete = false)
  vault_paths = get_vault_paths(del_path)
  vault_secrets = get_vault_secrets(vault_paths)

  unless force_delete
    puts vault_secrets
    puts 'Are you sure you want to delete ALL of these secrets and paths from Vault?'
    puts 'Type DELETE to proceed.'

    exit unless gets.chomp == 'DELETE'
  end

  vault_secrets.each do |secret|
    removal = Vault.logical.delete(secret)
    puts "Removing key #{secret}: #{removal ? 'succeeded' : 'failed'}"
  end

  vault_paths.reverse.each do |key|
    removal = Vault.logical.delete(key)
    puts "Removing path #{key}: #{removal ? 'succeeded' : 'failed'}"
  end
end

# Check that we have a vault token we can use
begin
  token = File.read("#{Dir.home}/.vault-token")
rescue Errno::ENOENT => e
  raise Errno::ENOENT, "Missing vault token file: #{e}"
end

# Sanity check the token
raise 'Your vault token is blank for some reason. Authenticate with vault first.' if token.nil? || token == ''

# Configure the Vault gem
Vault.configure do |vault|
  vault.address = vault_url
  vault.token = token
  vault.ssl_verify = false
end

# Delete some stuff
vault_recursive_delete(options[:path], options[:force])
