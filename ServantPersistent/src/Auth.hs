{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
{-# LANGUAGE DeriveGeneric   #-}
{-# LANGUAGE TypeFamilies #-}
module Auth
    where

import Data.Aeson
import Data.Aeson.TH
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Servant.API.Experimental.Auth
import Servant.Server.Experimental.Auth.Cookie
import Data.ByteString
import Data.Proxy
import GHC.Generics
import Data.Serialize
import Data.Text
import Types

type AppAuth = AuthProtect "cookie-auth"

type instance AuthCookieData = Session

validateLogin :: LoginForm -> App Bool
validateLogin _ = return True
