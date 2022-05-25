let l = require('./uncompressed-cf.json')
l.pop() // last one is empty, added by the to_json.sh script

// let b = l.filter(e=>!e.labels.includes('awswaf:managed:aws:bot-control'))
// let b = l.filter(e=>e.labels && e.labels.includes('awswaf:managed:aws:bot-control'))
// b = l.filter(e=>e.labels && e.labels.includes('awswaf:managed:aws:bot-control'))
// let bots  = l.filter(e=>e.labels && e.labels.includes('awswaf:managed:aws:bot-control'))

let labeled  = l.filter(e=>e.labels);
labeled.forEach(e=> e.labels= e.labels.map(i=>i.name)); // simplify for easier filtering
console.log('total requests', l.length, 'labeled requests', labeled.length);

let labels = labeled.map(e=>e.labels)
let lab = new Set()
labels.forEach(e=> e.forEach(n => lab.add(n)))
lab = [...lab].sort()
console.log('unique labels:',lab)

// let social = labeled.filter(e=>e.labels.includes('awswaf:managed:aws:bot-control:bot:category:social_media'))
// console.log('social bots: ', social.length)

let countries = new Set(l.map(e=>e.httpRequest.country))
console.log(l.length, 'requests came from these countries:', countries);

// let verified = labeled.filter(e=>e.labels.includes('awswaf:managed:aws:bot-control:bot:verified'))
// verified.length

fs.writeFileSync('labeled-cf.json',JSON.stringify(labeled,null,2))

// l.filter(e=>e.httpRequest.clientIpd == '52.77.238.223')
// let sg = l.filter(e=>e.httpRequest.clientIp == '52.77.238.223')
// // let sgnl = sg.filter(e=>!e.labels)
// sg.filter(e=>e.labels).map(e=>e.labels)
// sg.map(e=>`${e.httpRequest.httpMethod} ${e.httpRequest.uri}${e.httpRequest.args ? e.httpRequest.args: ''}`)
// let uris = new Set(sg.map(e=>`${e.httpRequest.httpMethod} ${e.httpRequest.uri}${e.httpRequest.args ? e.httpRequest.args: ''}`))

let bad = labeled.filter(e=>e.httpRequest.clientIp != '52.77.238.223'). // manually verified bot
                filter(e=>!e.labels.includes('awswaf:managed:aws:bot-control:bot:verified')).
                filter(e=>!e.labels.includes('awswaf:managed:aws:bot-control:bot:category:social_media')).
                filter(e=>!e.labels.includes('awswaf:managed:aws:bot-control:bot:category:search_engine')).
                filter(e=>!e.labels.includes('awswaf:managed:aws:bot-control:bot:category:http_library'))
                // filter(e=>!e.labels.includes("awswaf:managed:aws:bot-control:signal:non_browser_user_agent")). // these will be blocked next
                // filter(e=>!e.labels.includes("awswaf:managed:aws:bot-control:signal:known_bot_data_center")) // these will be blocked next
//map remaining to one per category:
let sample = {}
bad.forEach(e=>e.labels.forEach(label=>sample[label] = e))
fs.writeFileSync('bad-sample-cf.json',JSON.stringify(sample,null,2))

let counts = Object.keys(sample).map(label => ({[label]: bad.filter(e=>e.labels.includes(label)).length}))
console.log('request counts per bot category:', JSON.stringify(counts, null, 2))

// // new Set(bad.map(e=>`${e.httpRequest.httpMethod} ${e.httpRequest.uri}${e.httpRequest.args ? e.httpRequest.args: ''}`))
// // bad.filter(e=>e.httpRequest.uri == '/home').map(e=>e.labels)
// // bad.filter(e=>e.httpRequest.uri == '/').map(e=>e.labels)
// // bad.filter(e=>e.httpRequest.uri == '/' && e.httpRequest.httpMethod != 'GET')
// // let graphql = bad.filter(e=>e.httpRequest.uri == '/graphql')
// // graphql.length
// // console.log(JSON.stringify(graphql[0],null,2))

// // slim down before writing for manual inspection:
// bad.forEach(e=>delete e.rateBasedRuleList)
// bad.forEach(e=>delete e.httpSourceId)
// bad.forEach(e=>delete e.httpSourceName)
// bad.forEach(e=>delete e.weebaclId)
// bad.forEach(e=>delete e.nonTerminatingMatchingRules)
// bad.forEach(e=>delete e.ruleGroupList)
// bad.forEach(e=>delete e.webaclId)
// bad.forEach(e=>delete e.terminatingRuleId)
// bad.forEach(e=>delete e.requestHeadersInserted)
// bad.forEach(e=>delete e.responseCodeSent)
// bad.forEach(e=>delete e.terminatingRuleMatchDetails)

// // let allbad = bad
// // bad.filter(e=>e.httpRequest.uri.endsWith('.php')).length
// // bad = bad.filter(e=>!e.httpRequest.uri.endsWith('.php'))
// // bad.filter(e=>!e.httpRequest.uri.endsWith('.asp'))
// // bad.filter(e=>!e.httpRequest.uri.endsWith('.aspx'))
// // bad.filter(e=>!e.httpRequest.uri.endsWith('.asp'))
// // bad.filter(e=>!e.httpRequest.uri.endsWith('.env'))
// // bad = bad.filter(e=>!e.httpRequest.uri.endsWith('.env'))

fs.writeFileSync('bad-cf.json',JSON.stringify(bad,null,2))

// investigate blocked to see if some should be allowed:
let blocked = l.filter(e=>e.action !='ALLOW' && e.terminatingRuleType != "RATE_BASED")
fs.writeFileSync('blocked-cf.json',JSON.stringify(blocked,null,2))
