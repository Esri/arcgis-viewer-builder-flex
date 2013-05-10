////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008-2013 Esri. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
////////////////////////////////////////////////////////////////////////////////

/*
COPYRIGHT 2008-2012 ESRI

TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
Unpublished material - all rights reserved under the
Copyright Laws of the United States and applicable international
laws, treaties, and conventions.

For additional information, contact:
Environmental Systems Research Institute, Inc.
Attn: Contracts and Legal Services Department
380 New York Street
Redlands, California, 92373
USA

email: contracts@esri.com
*/
package com.esri.builder.controllers.supportClasses
{

import flash.events.DNSResolverEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.IPVersion;
import flash.net.InterfaceAddress;
import flash.net.NetworkInfo;
import flash.net.NetworkInterface;
import flash.net.dns.DNSResolver;
import flash.net.dns.PTRRecord;

import mx.rpc.IResponder;

//--------------------------------------
//  Events
//--------------------------------------

/**
 * Fires when the field value changed
 *
 * @eventType flash.events.Event
 */
[Event(name="change", type="flash.events.Event")]


/**
 * Utility class to figure out the network best suitable name of the computer.
 *
 * The hostname is determine following those rules:
 *      - localhost is the default fallback name.
 *      - if the computer is connected to a network, the IP address is chosen, unless...
 *      - if the DNS lookup succeed with the IP address, this is the chosen name.
 *
 * Known limitations:
 *      - On Windows the DNSResolver lookup doesn't return the hostname, IP is chosen
 */
public class MachineDisplayName extends EventDispatcher
{
    //--------------------------------------------------------------------------
    //
    //  Class Methods
    //
    //--------------------------------------------------------------------------

    public static function getInstance():MachineDisplayName
    {
        if (!instance)
        {
            instance = new MachineDisplayName();
        }
        return instance;
    }

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    private static var instance:MachineDisplayName;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     *
     */
    public function MachineDisplayName():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables 
    //
    //--------------------------------------------------------------------------

    /**
     * The DNS resolver to find computer's name
     */
    private var resolver:DNSResolver = new DNSResolver();

    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  name
    //----------------------------------

    /**
     * Storage for the DNS name property, read-only
     */
    private var m_name:String = null;

    [Bindable(event="change")]

    /**
     * The machine name.
     *
     * @default localhost
     */
    public function get name():String
    {
        return m_name;
    }

    private function setName(value:String):void
    {
        if (m_name !== value)
        {
            m_name = value;
            if (hasEventListener(Event.CHANGE))
            {
                dispatchEvent(new Event(Event.CHANGE));
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Lookup again for the machine name.
     */
    public function resolve(responder:IResponder = null):void
    {
        m_name = null;
        lookupForName(responder);
    }

    //--------------------------------------------------------------------------
    //
    //  Overriden Public Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @inheritDoc
     */
    override public function toString():String
    {
        return name;
    }

    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Figure out the machine name.
     */
    private function lookupForName(responder:IResponder = null):void
    {
        // Try to find the IP address
        var suitableIPAddress:String = findIpAddress();

        if (!suitableIPAddress)
        {
            // No IP address, so will say that the machine name is localhost
            setName("localhost");
            if (responder)
            {
                responder.result(name);
            }
        }
        else
        {
            // Function call in case of DNS lookup success
            var dnsResultHandler:Function = function(event:DNSResolverEvent):void
            {
                // on Windows, lookup currently return nothing, so we return the IP address
                if (event.resourceRecords.length == 0)
                {
                    setName(suitableIPAddress);
                    if (responder)
                    {
                        responder.result(name);
                    }
                }
                else
                {
                    var record:PTRRecord = event.resourceRecords[0] as PTRRecord;
                    if (record && record.ptrdName && record.ptrdName != null)
                    {
                        // computer hostname on the network
                        setName(record.ptrdName);
                        if (responder)
                        {
                            responder.result(name);
                        }
                    }
                    else
                    {
                        // no value, set with the IP address
                        // YCA: if no value, maybe localhost would a more suitable value?
                        setName(suitableIPAddress);
                        if (responder)
                        {
                            responder.result(name);
                        }
                    }
                }
            }

            // Function call in case of DNS lookup failure
            var dnsFaultHandler:Function = function(error:ErrorEvent):void
            {
                // YCA: if no value, maybe localhost would a more suitable value?
                setName(suitableIPAddress);
                if (responder)
                {
                    responder.result(name);
                }
            }

            // Start a DNS lookup with the IP address
            resolver.addEventListener(DNSResolverEvent.LOOKUP, dnsResultHandler);
            resolver.addEventListener(ErrorEvent.ERROR, dnsFaultHandler);
            resolver.lookup(suitableIPAddress, PTRRecord);
        }

    }

    /**
     * Try to find a valid IP address
     *
     * @return The IP address, if found, or null
     */
    private function findIpAddress():String
    {
        var ipAddress:String = null;

        var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();

        loop: for each (var interfaceObj:NetworkInterface in interfaces)
        {
            if (interfaceObj.active)
            {
                if (interfaceObj.addresses && interfaceObj.addresses.length > 0)
                {
                    for each (var address:InterfaceAddress in interfaceObj.addresses)
                    {
                        if (address.address != "127.0.0.1" && address.ipVersion == IPVersion.IPV4)
                        {
                            ipAddress = address.address;
                            break loop;
                        }
                    }
                }
            }
        }

        return ipAddress;
    }
}
}
