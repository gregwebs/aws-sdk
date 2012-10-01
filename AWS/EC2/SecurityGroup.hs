{-# LANGUAGE FlexibleContexts, RankNTypes #-}

module AWS.EC2.SecurityGroup
    ( describeSecurityGroups
    ) where

import Data.Text (Text)

import Data.XML.Types (Event)
import Data.Conduit
import Control.Monad.Trans.Control (MonadBaseControl)
import Control.Applicative

import AWS.EC2.Types
import AWS.EC2.Class
import AWS.EC2.Query
import AWS.EC2.Parser
import AWS.Util

describeSecurityGroups
    :: (MonadResource m, MonadBaseControl IO m)
    => [Text] -- ^ GroupNames
    -> [Text] -- ^ GroupIds
    -> [Filter] -- ^ Filters
    -> EC2 m (Source m SecurityGroup)
describeSecurityGroups names ids filters =
    ec2QuerySource "DescribeSecurityGroups" params
    $ itemConduit "securityGroupInfo" $
        SecurityGroup
        <$> getT "ownerId"
        <*> getT "groupId"
        <*> getT "groupName"
        <*> getT "groupDescription"
        <*> getMT "vpcId"
        <*> ipPermissionsSink "ipPermissions"
        <*> ipPermissionsSink "ipPermissionsEgress"
        <*> resourceTagSink
  where
    params =
        [ ArrayParams "GroupName" names
        , ArrayParams "GroupId" ids
        , FilterParams filters
        ]

ipPermissionsSink :: MonadThrow m
    => Text -> GLSink Event m [IpPermission]
ipPermissionsSink name = itemsSet name $ IpPermission
    <$> getT "ipProtocol"
    <*> getM "fromPort" (textToInt <$>)
    <*> getM "toPort" (textToInt <$>)
    <*> itemsSet "groups" (
        UserIdGroupPair
        <$> getT "userId"
        <*> getT "groupId"
        <*> getMT "groupName"
        )
    <*> itemsSet "ipRanges" (IpRange <$> getT "cidrIp")
