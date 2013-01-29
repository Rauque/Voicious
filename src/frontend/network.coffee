###

Copyright (c) 2011-2012  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

class NetworkManager
    constructor   : (hostname, port) ->
        @networkConfig            = {}
        @networkConfig.hostname   = hostname
        @networkConfig.port       = port
        
        @connections              = {}

    createPeerConnection : (options) =>
        cid               = options.cinfo.cid
        localStream       = window.localStream
        
        if localStream?
            options.stream = localStream

        options.tunnel          = @socket

        options.gotstream       = (event) =>
            trace "Add new stream"
            baliseVideoId   = 'video' + cid
            baliseBlockId   = "block" + cid
            $("#videos").append(
                '<div id="' + baliseBlockId + '" class="video-block">
                 <p>Callee - ' + cid + '</p>
                 <video id="' + baliseVideoId + '" autoplay="autoplay" class="videoStream"></video>
                 </div>'
                )
            baliseName          = '#' + baliseVideoId
            $(baliseName).attr 'src', window.URL.createObjectURL(event.stream)

        options.removestream    = (event) =>
            trace "Remove stream"

        options.getice          = (tunnel, event) =>
            if (event.candidate)
              @onSend tunnel, ["candidate", options.cinfo,
              {
              type: 'candidate',
              label: event.candidate.sdpMLineIndex,
              id: event.candidate.sdpMid, candidate: event.candidate.candidate
              }]
            else
              trace "End of candidates."

        options.onCreateAnswer  = (tunnel, sessionDescription) =>
            @onSend tunnel, ["answer", options.cinfo, sessionDescription.sdp]

        pc  = PeerConnection options

        obj =
          peerConnection  : pc
          cinfo           : options.cinfo
        @connections[cid] = obj

    negociatePeersOffer : (stream) =>
        for key, val of @connections
            trace "Negociate new offer" + key
            do (key, val) =>
                trace "Call addStream" + key
                pc = val.peerConnection
                pc.addStream(stream)
                pc.peerCreateOffer (tunnel, offer) =>
                    @onSend tunnel, ["offer", val.cinfo, offer.sdp]

    onOpen              : () =>
        roomId = $("#infos").attr("room")
        token = $("#infos").attr("token") # delete token from the infos
        @onSend @socket, ["authentification", roomId, token]

    onMessage           : (message) =>
        args        = JSON.parse(message.data)

        eventName   = args[0]
        cinfos      = args[1]
        sdp         = args[2]
        
        trace "Received : #{args}"
        switch (eventName)
            when 'peers'
                trace "on peers"
                cinfos.forEach (cinfo, i) =>
                    options =
                        cinfo     : cinfo
                        onoffer   : (tunnel, offer) =>
                            @onSend tunnel, ["offer", cinfo, offer.sdp]

                    @createPeerConnection options
            when 'peer.create'
                trace "on peer create"

                options   =
                    cinfo   : cinfos

                @createPeerConnection options

            when 'peer.remove'
                trace "on peer remove"

                cinfo     = cinfos
                peerInfos = @connections[cinfo.cid]

#                if peerInfos? and peerInfos.peerConnection?
                peerInfos.peerConnection.close()

                baliseBlockId = "#block" + cinfo.cid
                $(baliseBlockId).remove()

                    #delete peerInfos.peerConnection
                delete @connections[cinfo.cid]

            when 'offer'
                trace('on offer')

                cinfo = cinfos
                pc    = @connections[cinfo.cid].peerConnection

                pc.peerCreateAnswer {sdp: sdp, type: 'offer'}

            when 'answer'
                trace "on answer"

                cinfo     = cinfos
                peerInfos = @connections[cinfo.cid]

                if peerInfos?
                    pc = peerInfos.peerConnection
                    pc.onanswer {sdp: sdp, type: 'answer'}

            when 'candidate'
                trace "add ice candidate"

                cinfo       = cinfos
                pc          = @connections[cinfo.cid].peerConnection
                
                pc.addice(sdp)
    
    onSend              : (tunnel, message) ->
        msg = JSON.stringify message
        trace "Send : #{msg}"
        tunnel.send msg
    
    connection          : () =>
        @socket           = new WebSocket "ws://#{@networkConfig.hostname}:#{@networkConfig.port}/"
        @tunnel           = @socket
        @socket.onopen    = () =>
            do @onOpen
        @socket.onmessage = (message) =>
            @onMessage message

NM  = (hostname, port) ->
    new NetworkManager hostname, port

if window?
    window.NetworkManager     = NM
if exports?
    exports.NetworkManager    = NM