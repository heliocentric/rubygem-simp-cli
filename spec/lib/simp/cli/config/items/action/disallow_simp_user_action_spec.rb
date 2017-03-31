require 'simp/cli/config/items/action/disallow_simp_user_action'
require 'simp/cli/config/items/data/cli_network_hostname'
require 'simp/cli/config/items/data/simp_server_allow_simp_user'
require 'rspec/its'
require_relative '../spec_helper'
require 'fileutils'

describe Simp::Cli::Config::Item::DisallowSimpUserAction do
  before :each do
    @ci        = Simp::Cli::Config::Item::DisallowSimpUserAction.new
    @ci.silent = true
  end

  context '#apply' do
    before :each do
      @tmp_dir        = Dir.mktmpdir( File.basename( __FILE__ ) )
      @fqdn           = 'hostname.domain.tld'
      @files_dir      = File.expand_path( 'files', File.dirname( __FILE__ ) )
      @tmp_yaml_file  = File.join( @tmp_dir,   "#{@fqdn}.yaml" )
      @ci.dir         = @tmp_dir

      item = Simp::Cli::Config::Item::CliNetworkHostname.new
      item.value  = @fqdn
      @ci.config_items[item.key] = item

      item = Simp::Cli::Config::Item::SimpServerAllowSimpUser.new
      item.value  = false
      @ci.config_items[item.key] = item
    end

    after :each do
      FileUtils.remove_entry_secure @tmp_dir
    end

    it "adds simp::server::allow_simp_user to <host>.yaml" do
      file = File.join(@files_dir, 'host_without_allow_simp_user.yaml')
      FileUtils.copy_file file, @tmp_yaml_file

      @ci.apply
      expect( @ci.applied_status ).to eq :succeeded
      expected = File.join(@files_dir, 'host_with_allow_simp_user_added.yaml')
      expected_content = IO.read(expected)
      actual_content = IO.read(@tmp_yaml_file)
      expect( actual_content).to eq expected_content
    end

    it 'replaces simp::server::allow_simp_user in <host>.yaml' do
      file = File.join( @files_dir,'puppet.your.domain.yaml')
      FileUtils.copy_file file, @tmp_yaml_file

      @ci.apply
      expect( @ci.applied_status ).to eq :succeeded
      expected = File.join(@files_dir, 'host_with_allow_simp_user_replaced.yaml')
      expected_content = IO.read(expected)
      actual_content = IO.read(@tmp_yaml_file)
      expect( actual_content).to eq expected_content
    end

    it 'fails when <host>.yaml does not exist' do
      @ci.apply
      expect( @ci.applied_status ).to eq(:failed)
    end

    it "fails when cli::network::hostname item does not exist" do
      @ci.config_items.delete('cli::network::hostname')
      expect{ @ci.apply }.to raise_error( Simp::Cli::Config::MissingItemError,
        'Internal error: Simp::Cli::Config::Item::DisallowSimpUserAction' +
        ' could not find cli::network::hostname' )
    end

    it "fails when simp::server::allow_simp_user item does not exist" do
      @ci.config_items.delete('simp::server::allow_simp_user')
      file = File.join( @files_dir,'puppet.your.domain.yaml')
      FileUtils.copy_file file, @tmp_yaml_file
      expect{ @ci.apply }.to raise_error( Simp::Cli::Config::MissingItemError,
        'Internal error: Simp::Cli::Config::Item::DisallowSimpUserAction' +
        ' could not find simp::server::allow_simp_user' )
    end

    it_behaves_like "an Item that doesn't output YAML"
    it_behaves_like 'a child of Simp::Cli::Config::Item'
  end
end
