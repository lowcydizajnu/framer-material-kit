m = require 'material-kit'

exports.defaults = {
	title:"Title"
	leftAction:undefined
	right:"Edit"
	blur:true
	superLayer:undefined
	type:"navBar"
	backgroundColor:"white"
	tabs:undefined
	titleColor:"black"
	actionColor:"black"
	tabs:undefined
	tabsColor:undefined
	tabsInk:{color:"blueGrey", scale:8}
	tabsBarColor:"yellow"
	tabsAlt:{color:undefined, opacity:.7}
	tabIcons:undefined
}

exports.defaults.props = Object.keys(exports.defaults)

exports.create = (array) ->
	setup = m.utils.setupComponent(array, exports.defaults)
	bar = new Layer
		name:"App Bar"
		backgroundColor:setup.backgroundColor
		shadowColor: "rgba(0, 0, 0, .12)"
		shadowBlur: m.px(4)
		shadowY: m.px(2)

	bar.constraints =
		leading:0
		trailing:0
		top:0
		height:80

	if setup.tabs
		bar.constraints.height = 128

	barArea = new Layer superLayer:bar, backgroundColor:"transparent"
	barArea.constraints =
		leading:0
		trailing:0
		height:56
		bottom:0

	if setup.tabs && setup.tabs.length > 2
		barArea.constraints.bottom = 48

	if setup.superLayer
		setup.superLayer.addSubLayer(bar)

	m.layout.set([bar, barArea])

	bar.type = setup.type

	for layer in Framer.CurrentContext.layers
		if layer.type == "statusBar"
			@statusBar = layer
			bar.placeBehind(@statusBar)

	if setup.titleColor == "black"
		setup.titleColor = m.utils.autoColor(setup.backgroundColor).toHexString()

	if setup.actionColor == "black"
		setup.actionColor = m.utils.autoColor(setup.backgroundColor).toHexString()

	if typeof setup.title == "string"
		title = new m.Text
			color:setup.titleColor
			fontWeight:500
			superLayer:barArea
			text:setup.title
			fontSize:20

	m.utils.specialChar(title)

	title.constraints =
		bottom:12
		leading:16

	if setup.leftAction
		title.constraints.leading = 73

	m.layout.set
		target:[title]

	if setup.tabs && setup.tabs.length > 2

		handleTabStates = (bar, layer) ->
			tabsArray = Object.keys(bar.tabs)
			activeTabIndex = undefined
			for t, i in tabsArray
				tab = bar.tabs[t]

				if tab == bar.activeTab
					activeTabIndex = i
					bar.views[t].animate
						properties:(x:0)
						time:.25
					tab.label.opacity = 1
					tab.label.color = setup.tabsColor
					bar.activeBar.animate
						properties:(x:layer.x)
						time:.25
						curve:"bezier-curve(.2, 0.4, 0.4, 1.0)"
					m.utils.update(title, [{text:m.utils.capitalize(bar.activeTab.label.name)}])
				else
					if activeTabIndex == undefined
						bar.views[t].animate
							properties:(x:m.device.width * -1)
							time:.25
							curve:"cubic-bezier(0.4, 0.0, 0.2, 1)"
					else
						bar.views[t].animate
							properties:(x:m.device.width)
							time:.25
							curve:"cubic-bezier(0.4, 0.0, 0.2, 1)"

					opacity = 1
					color = tab.label.color
					if setup.tabsAlt.opacity != undefined
						opacity = setup.tabsAlt.opacity

					if setup.tabsAlt.color != undefined
						color = setup.tabsAlt.color

					tab.label.opacity = opacity
					tab.label.color = color

		tabsActiveBar = new Layer
			height:m.px(2)
			width:m.device.width/setup.tabs.length
			backgroundColor:m.color(setup.tabsBarColor)
			superLayer:bar
		tabsActiveBar.constraints =
			bottom:0
		bar.activeBar = tabsActiveBar

		bar.tabs = {}
		bar.views = {}
		if setup.tabs.length < 5
			for t, i in setup.tabs
				view = new Layer
					name:"View " + t
					backgroundColor:"transparent"
				view.constraints =
					top:bar
					bottom:0
					width:m.dp(m.device.width)
				bar.views[t] = view
				if i > 0
					view.x = m.device.width
				tab = new Layer
					width:m.device.width/setup.tabs.length
					height:m.px(48)
					x:(m.device.width/setup.tabs.length) * i
					superLayer:bar
					backgroundColor:"transparent"
					clip:true
					name:"tab "
				tab.constraints =
					bottom:0
				m.layout.set(tab)
				if setup.tabsColor == undefined
					setup.tabsColor = m.utils.autoColor(setup.backgroundColor).toHexString()
				label = ""
				if setup.tabIcons
					icon = setup.tabIcons[i]
					label = new m.Icon
						name:icon
						superLayer:tab
						color:setup.tabsColor
						constraints:{align:"center"}
				else
					label = new m.Text
						superLayer:tab
						constraints:{align:"center"}
						text:t
						textTransform:'Uppercase'
						fontSize:14
						color:setup.tabsColor
				label.name = t

				tab.label = label

				setup.tabsInk["layer"] = tab
				m.utils.inky(setup.tabsInk)
				bar.tabs[t] = tab

				tab.on Events.TouchEnd, ->
					bar.activeTab = @
					handleTabStates(bar, @)

	bar.activeTab = bar.tabs[setup.tabs[0]]
	bar.title = title
	handleTabStates(bar, bar.activeTab)


	return bar
