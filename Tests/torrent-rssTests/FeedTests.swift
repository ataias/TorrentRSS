//
//  File.swift
//  
//
//  Created by Ataias Pereira Reis on 23/04/20.
//

import Foundation

let rssFeed = """
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
<title>RSS Title</title>
<description>A description of this feed</description>
<link>http://www.ataias.com.br</link>
<item>
<title>Filename 1.something</title>
<link>magnet:?xt=urn:btih:RANDOMCODEHERE1&amp;\
tr=http://ataias-tracker.br:7777/announce</link>
<guid isPermaLink="false">RANDOMCODEHERE1</guid>
<pubDate>Wed, 22 Apr 2020 14:34:48 +0000</pubDate>
</item>
<item>
<title>Filename 2.something</title>
<link>magnet:?xt=urn:btih:RANDOMCODEHERE2&amp;\
tr=http://ataias-tracker.br:7777/announce</link>
<guid isPermaLink="false">RANDOMCODEHERE2</guid>
<pubDate>Tue, 21 Apr 2020 14:34:48 +0000</pubDate>
</item>
<item>
<title>Filename 3.something</title>
<link>magnet:?xt=urn:btih:RANDOMCODEHERE3&amp;\
tr=http://ataias-tracker.br:7777/announce</link>
<guid isPermaLink="false">RANDOMCODEHERE3</guid>
<pubDate>Wed, 20 Apr 2020 14:34:48 +0000</pubDate>
</item>
</channel>
</rss>
"""

rssFeed.write(toFile: "test.rss", atomically: true, encoding: String.Encoding.utf8)
