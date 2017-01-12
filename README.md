# shakespeare-elm

A work-in-progress toy project to allow Elm to plug in nicely into Yesod's
widget system.

## Usage

You can use `shakespeare-elm` inside any `WidgetT` monad.

Assume we have a `<div id='elm'>` available in homepage. Then we can add `shakespeare-elm` to hook into that div and let Elm take over. Add this to your home page `Handler`:

```hs
import qualified Data.Elm as Elm

getHomeR :: Handler Html
getHomeR = do
    defaultLayout $ do
        if (appReloadTemplates compileTimeAppSettings) then
            toWidget $(Elm.elmFileReload "elm/Main.elm")
        else
            toWidget $(Elm.elmFile "elm/Main.elm")

        toWidget [julius| Elm.Main.embed(document.getElementById('elm')); |]
        $(widgetFile "homepage")
```

Based on your current ENV, it will either reload the file or keep using the same cached file.

## TODO

* Figure out why `elmFileReload` does not trigger a recompile on every request.
