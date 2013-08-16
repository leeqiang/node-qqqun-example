node-qqqun
==========

提供抓取QQ群数据接口

## 配置config.coffee

```
	appId: xxxxxxxx
	appKey: xxxxxxxxx

	errorPage: 报错提示页面
```

## 数据调用接口
```
	/qqqun
	params: 
		openid
		openkey
		groupopenid
	method: GET
	response:
		{
			organization: {
				openId: "xxxxxxxxxxxxxxxxx",
				name: "group name"
			},
			user: {
				openId: "XXXXXXX",
				location: "XXXX",
				avatarUrl: "xxxxxxxx",
				email: "xxxx",
				name: "nickname"
			},
			members: [
				{
					openId: "XXXXXXX",
					location: "XXXX",
					avatarUrl: "xxxxxxxx",
					email: "xxxx",
					name: "nickname"
				}
			]
		}
```

## 启动
```
	coffee app.coffee
```
