FeedSource.create! url: 'http://leipzig-hrm-blog.blogspot.com/feeds/posts/default', name: 'Leipziger HRM Blog', value: 20
FeedSource.create! url: 'http://martingaedt.de/feed/', name: 'Martin Gaedt', value: 0
TwitterSource.create!(url: 'petermwald', name: 'petermwald', value: 5)
FeedSource.create! url: 'http://www.hzaborowski.de/feed/', name: 'hzaborowski', value: 0
FeedSource.create! url: 'http://noch-ein-hr-blog.de/feed/', name: 'Noch ein HR Blog', value: 0
FeedSource.create! url: 'http://www.saatkorn.com/feed', name: 'Saatkorn', value: 0
Source.find(29).destroy
Source.find(37).destroy
Source.find(31).destroy
