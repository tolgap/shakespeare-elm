# shakespeare-elm

A work-in-progress toy project to allow Elm to plug in nicely into Yesod's
widget system.

## Usage

First we need to make Yesod aware that Elm is a thing.

### Registering Elm as a widgetFile

When scaffolding a new Yesod project, a file `Settings.hs` is generated.

Replace `widgetFileSettings = def` with the following, and add the imports as well:

```hs
import qualified Text.Elm
import Yesod.Default.Util ( WidgetFileSettings
                          , TemplateLanguage (TemplateLanguage)
                          , widgetFileNoReload
                          , widgetFileReload
                          , wfsLanguages
                          , defaultTemplateLanguages
                          )

{- some lines ... -}

widgetFileSettings :: WidgetFileSettings
widgetFileSettings = def { wfsLanguages = \hset -> defaultTemplateLanguages hset ++
    [ TemplateLanguage True "elm" Text.Elm.elmFile Text.Elm.elmFileReload
    ] }
```

This will allow you to use the `widgetFile` function to automagically
compile to JS using `shakespeare-elm`.

### widgetFile

You can use `shakespeare-elm` inside any `WidgetT` monad.

Assume we have a `<div id='elm'>` available in homepage. Then we can add `shakespeare-elm` to hook into that div and let Elm take over. Add this to your home page `Handler`:

```hs
import Text.Elm (forceElmFileReload)

getHomeR :: Handler Html
getHomeR = do
    defaultLayout $ do
        if (appReloadTemplates compileTimeAppSettings) then
            lift $ forceElmFileReload "templates/elm/Main.elm"
        else
            return ()

        $(widgetFile "elm/Main.elm")
        toWidget [julius| Elm.Main.embed(document.getElementById('elm')); |]
        $(widgetFile "homepage")
```

Based on your current ENV, it will either reload the file or keep using the same cached file.

This flow assume that your Elm files live in `templates/elm`. Make sure
to also set your `elm-package.json` source directory to `'templates/elm'`
instead of the default `'.'` or `'./src'`.
