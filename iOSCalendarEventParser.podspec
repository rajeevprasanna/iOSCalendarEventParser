Pod::Spec.new do |s|
s.platform = :ios
s.name         = 'iOSCalendarEventParser'
s.version      = '0.0.4'
s.license      = { :type => 'MIT' }
s.homepage     = 'https://github.com/rajeevprasanna/iOSCalendarEventParser'
s.authors      = { "rajeevprasanna" => "rajeevprasanna@gmail.com" }
s.summary      = 'A set of classes used to parse and handle iCalendar (.ICS) files'
s.source       = { :git => "https://github.com/rajeevprasanna/iOSCalendarEventParser.git", :tag => s.version.to_s }
s.source_files = 'CalendarManager/*.{h,m}'
s.frameworks = 'UIKit', 'Foundation'
s.requires_arc = true
end