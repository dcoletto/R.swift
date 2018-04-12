use_frameworks!

workspace 'ResourceApp'
project 'ResourceApp/ResourceApp'

abstract_target 'Shared' do
  inhibit_all_warnings!

  #pod 'R.swift.Library', :git => 'git@github.com:mac-cain13/R.swift.Library.git' # for CI builds
  pod 'R.swift', :path => '.' # for development

  target 'ResourceApp' do
    pod 'SWRevealViewController'
  end
  target 'ResourceAppTests' do
    pod 'SWRevealViewController'
  end
  target 'ResourceApp-tvOS'

end

