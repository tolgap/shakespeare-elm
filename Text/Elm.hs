{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE CPP #-}
{-# OPTIONS_GHC -fno-warn-missing-fields #-}
module Text.Elm
    (
      elm
    , elmFile
    , elmFileReload
    ) where

import System.Posix.Files (touchFile)
import Language.Haskell.TH.Quote (QuasiQuoter (..))
import Language.Haskell.TH.Syntax
import Text.Shakespeare
import Text.Julius
import Control.Monad (liftM)

elmSettings :: Q ShakespeareSettings
elmSettings = do
    jsettings <- javascriptSettings
    return $ jsettings { varChar = '#'
    , preConversion = Just PreConvert {
        preConvert = ReadProcess "sh" ["-c", "TMP_IN=$(mktemp).elm; TMP_OUT=$(mktemp).js; cat /dev/stdin > ${TMP_IN} && elm-make --output ${TMP_OUT} ${TMP_IN} &> /dev/null && cat ${TMP_OUT}; rm ${TMP_IN} && rm ${TMP_OUT}"]
      , preEscapeIgnoreBalanced = "'\""
      , preEscapeIgnoreLine = "{-"
      , wrapInsertion = Nothing
      }
    }


elm :: QuasiQuoter
elm = QuasiQuoter { quoteExp = \s -> do
    rs <- elmSettings
    quoteExp (shakespeare rs) s
    }


elmFile :: FilePath -> Q Exp
elmFile fp = do
    rs <- elmSettings
    shakespeareFile rs fp


elmFileReload :: FilePath -> Q Exp
elmFileReload fp = do
    -- HACK: this sets the modified time of the Elm file so shakespeare's runtime
    -- will force reload it, in case dependencies have been edited.
    runIO $ touchFile fp
    rs <- elmSettings
    shakespeareFileReload rs fp
