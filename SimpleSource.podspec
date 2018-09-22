Pod::Spec.new do |s|
  s.name                 = 'SimpleSource'
  s.version              = '1.0.1'
  s.summary              = 'Composable, easy to use data sources for UITableView and UICollectionView.'
  s.homepage             = 'https://github.com/Squarespace/simple-source'
  s.license              = { :type => 'Apache', :file => 'LICENSE' }
  s.authors              = { 'Morten Heiberg' => 'mheiberg@squarespace.com', 'Thor Frolich' => 'tfrolich@squarespace.com' }
  s.platform             = :ios, '9.0'
  s.swift_version        = '4.0'
  s.source               = { :git => 'https://github.com/Squarespace/simple-source.git', :tag => s.version }
  s.source_files         = 'Sources/**/*.{h,m,swift}'
  s.dependency           'Dwifft', '0.7'

  s.test_spec 'Tests' do |test_spec|
    test_spec.resource = 'Tests/Model/*.xcdatamodeld'
    test_spec.source_files = 'Tests/**/*.swift'
    test_spec.dependency 'Nimble'
    test_spec.dependency 'Quick'
  end  
end

