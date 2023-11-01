Pod::Spec.new do |s|
  s.name                 = 'SimpleSource'
  s.version              = '3.0.2'
  s.summary              = 'Composable, easy to use data sources for UITableView and UICollectionView.'
  s.homepage             = 'https://github.com/Squarespace/simple-source'
  s.license              = { :type => 'Apache', :file => 'LICENSE' }
  s.authors              = { 'Morten Heiberg' => 'mheiberg@squarespace.com', 'Thor Frolich' => 'tfrolich@squarespace.com' }
  s.platform             = :ios, '13.0'
  s.swift_version        = '5.7'
  s.source               = { :git => 'https://github.com/Squarespace/simple-source.git', :tag => s.version }
  s.source_files         = 'Sources/' + s.name + '/**/*.{h,m,swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.resource = 'Tests/' + test_spec.name.gsub("/", "") + '/Resources/*.xcdatamodeld'
    test_spec.source_files = 'Tests/' + test_spec.name.gsub("/", "") + '/**/*.swift'
    test_spec.dependency 'Nimble', '~> 12.0'
    test_spec.dependency 'Quick', '~> 7.0'
  end
end

