Gem::Specification.new do |s|
  s.name     = "object_mock"
  s.version  = "0.1.2"
  s.date     = "2010-04-19"
  s.summary  = "A simple, flexible and reversible mocking solution"
  s.email    = "mohammed.shalaby@espace.com.eg"
  s.homepage = "http://github.com/mshalaby/object_mock"
  s.description = "A group of methods added to Object class to enable simple mocking of instance or class methods. This mocking can be done temporarily within the scope of a block. Alternatively it can be done indefinitely until explicitly undone."
  s.has_rdoc = true
  s.authors  = ["Mohammed Shalaby"]
  s.files    = [ 
                "object_mock.gemspec", 
                "README.rdoc",
                "lib/object_mock.rb"
  ]
end
