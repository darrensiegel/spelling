// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

var data = null;
var stream = null;
var recorder = null;
var lastPlayed = null;

let Hooks = {}
Hooks.AudioRecord = {
    mounted() {

        navigator.mediaDevices.getUserMedia({
            audio: true
        })
            .then(function (s) {
                stream = s;
                recorder = new MediaRecorder(stream);
                recorder.addEventListener('dataavailable', onRecordingReady);

            });
        this.el.addEventListener("click", e => {
            recorder.start();
            this.pushEvent("record", {});
        });

    }
}

Hooks.InputBox = {
    updated() {

        this.el.value = this.el.getAttribute("class");
    }
}

Hooks.AudioClip = {
    mounted() {
        console.log('mounted')
    },
    updated() {
        var audio = document.getElementById('audio');
        if (audio.src) {
            audio.play();

        }

    }
}


function playClip(clipId) {
  if (lastPlayed === clipId) return;
  lastPlayed = clipId;
  const mark = Date.now()
  fetch("/api/clip/" + clipId)
      .then(response => response.text())
      .then(clip => {
          var audio = new Audio(clip);
          console.log(Date.now() - mark)
          audio.play();
      });
}

Hooks.AudioClipPlay = {
    mounted() {
        console.log('mounted')
        const clipId = this.el.getAttribute("data-clip-id");
        playClip(clipId);
    },
    updated() {
        console.log("updated");
        const clipId = this.el.getAttribute("data-clip-id");
        playClip(clipId);
        

    }
}

Hooks.ClickPlay = {

    mounted() {

        this.el.addEventListener("click", () => {

            const clipId = this.el.getAttribute("data-clip-id");
            const mark = Date.now()
            fetch("/api/clip/" + clipId)
                .then(response => response.text())
                .then(clip => {
                    var audio = new Audio(clip);
                    console.log(Date.now() - mark)
                    audio.play();
                });
        });



    }
}


Hooks.ChoiceButton = {

    updated() {
        console.log(this.el.getAttribute("class"));
        if (this.el.getAttribute("class").indexOf("negative") != -1) {
            $('#' + this.el.getAttribute('id'))
                .transition('bounce')
                ;
        } else if (this.el.getAttribute("class").indexOf("positive") != -1) {
            $('#' + this.el.getAttribute('id'))
                .transition('tada')
                ;
        }
    }
}
Hooks.Image = {
    mounted() {
        $('#' + this.el.getAttribute('id'))
            .transition('fly in')
            ;
    }
}



Hooks.AudioSave = {
    mounted() {
        this.el.addEventListener("click", e => {
            var reader = new FileReader();
            reader.onload = (event) => {
                const clip = event.target.result;
                console.log(clip);
                this.pushEvent("save", { clip, test: 'test' });
            };
            reader.readAsDataURL(data);
        })
    }
}

Hooks.AudioStop = {
    mounted() {
        this.el.addEventListener("click", e => {
            recorder.stop();
            this.pushEvent("stop", {});
        })
    }
}

Hooks.AudioWord = {
    mounted() {
        this.el.addEventListener("input", e => {
            this.pushEvent("word", { value: this.el.value });
        })
    }
}

function onRecordingReady(e) {
    var audio = document.getElementById('audio');
    // e.data contains a blob representing the recording
    audio.src = URL.createObjectURL(e.data);

    data = e.data;
    audio.play();
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: {_csrf_token: csrfToken}});
liveSocket.connect()
