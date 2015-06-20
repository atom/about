{ScrollView} = require 'atom-space-pen-views'

module.exports =
class AboutView extends ScrollView
  @content: ->
    @div class: 'pane-item native-key-bindings about-atom', tabindex: -1, =>
      @div class: 'panel', =>
        @img class: 'atom-icon', src: 'atom://about/assets/atom.png'
        @div class: 'atom-version', outlet: 'atomVersion'
        @button outlet: 'copyAtomVersion', class: 'btn icon icon-clippy'
        @div class: 'credits', outlet: 'credits', =>
          @span class: 'icon icon-code'
          @span class: 'inline', 'with'
          @span class: 'icon icon-heart'
          @span class: 'inline', 'by'
          @a class: 'icon icon-logo-github', href: 'https://github.com'
          @p '''
            Thundercats paleo wayfarers, Etsy jean shorts photo booth mustache Helvetica normcore single-origin coffee retro. Semiotics tousled Wes Anderson, Tumblr kogi hoodie roof party bitters direct trade letterpress typewriter lo-fi. Etsy brunch Pitchfork, cardigan four dollar toast cronut fap roof party. Church-key selfies four loko retro, Neutra drinking vinegar craft beer yr flexitarian listicle DIY Kickstarter photo booth. Distillery put a bird on it drinking vinegar butcher. Direct trade High Life Pitchfork pug, mumblecore tofu sriracha scenester trust fund selfies bitters before they sold out hoodie tote bag lo-fi. Four loko kitsch retro cliche, single-origin coffee tofu disrupt cornhole heirloom YOLO keffiyeh.

            Helvetica viral kitsch yr, tilde Tumblr art party High Life umami deep v. Blue Bottle organic wolf Brooklyn Austin Neutra. Heirloom seitan banjo, actually drinking vinegar try-hard farm-to-table meggings beard +1 lo-fi listicle biodiesel semiotics readymade. Disrupt Godard health goth, synth skateboard gentrify kogi banh mi typewriter PBR Schlitz you probably haven't heard of them photo booth. Cray irony ethical Portland, gluten-free master cleanse kale chips chillwave mumblecore hashtag you probably haven't heard of them. Skateboard meh fashion axe VHS plaid. YOLO keffiyeh Blue Bottle bitters.

            Polaroid aesthetic lumbersexual organic Etsy. Hella paleo letterpress roof party, cronut meggings four loko. Pug Intelligentsia meditation vinyl. Wes Anderson fanny pack PBR, kogi you probably haven't heard of them yr mlkshk brunch quinoa stumptown squid health goth crucifix. Gentrify four loko ugh, irony next level kale chips letterpress Carles hoodie Shoreditch skateboard butcher aesthetic distillery. Blue Bottle Banksy cray, Pinterest slow-carb Echo Park single-origin coffee street art viral shabby chic four dollar toast kitsch Etsy. Viral mixtape Kickstarter, raw denim irony Odd Future lo-fi quinoa yr tote bag cred four loko Helvetica.

            DIY ennui Bushwick chambray, pork belly meggings fashion axe fixie Blue Bottle you probably haven't heard of them typewriter roof party drinking vinegar next level readymade. Fixie organic irony, quinoa narwhal pork belly mlkshk keytar asymmetrical scenester heirloom Neutra. Wes Anderson Thundercats paleo, mixtape farm-to-table street art stumptown cliche DIY actually aesthetic art party Neutra. Umami locavore irony roof party Brooklyn, Helvetica tilde chia. Ugh semiotics VHS, sartorial PBR&B banh mi PBR +1 art party bicycle rights deep v Intelligentsia. Normcore polaroid VHS American Apparel, tilde gentrify PBR&B cliche Williamsburg beard quinoa dreamcatcher Brooklyn. Gastropub asymmetrical ennui, viral paleo meggings selvage mustache banjo.
            '''

  initialize: ({@uri}) ->
    @atomVersion.text(atom.getVersion())

    @copyAtomVersion.on 'click', =>
      atom.clipboard.write(@atomVersion.text())

  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()

  getURI: -> @uri

  getTitle: -> 'About'

  getIconName: -> 'info'
