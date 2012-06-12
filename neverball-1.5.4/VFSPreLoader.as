////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.events.AsyncErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.display.LoaderInfo;
    import flash.display.Graphics;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import nochump.util.zip.*;

	public class VFSPreLoader extends MovieClip
	{	
		var progress:TextField
        var loader:Loader
        var params
        var fail = false
        var childDomain = null
        private var datazips:Array = [];
        private var engineLoaded:Boolean = false;

        var vfscomplete:Boolean, enginecomplete:Boolean

		public function VFSPreLoader() 
		{
          addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        public function setStatus(s:String)
        {
            if(!fail)
                progress.text = s
        }

        private function onAddedToStage(e:*)
        {
            trace("VFSPreLoader")
            var fmt:TextFormat = new TextFormat();
            fmt.size = 24;
            fmt.align = TextFormatAlign.CENTER;

            progress = new TextField()
            progress.defaultTextFormat = fmt;
			progress.x = 0
			progress.y = 350
			progress.width = 1024
			progress.height = 100
            addChild(progress)
            stage.frameRate = 60

            var datazip1 = new URLLoader(new URLRequest("data1.zip"));
            datazip1.dataFormat = URLLoaderDataFormat.BINARY;
            datazip1.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError)
            datazip1.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError)
            datazip1.addEventListener(IOErrorEvent.IO_ERROR, onError)
            datazip1.addEventListener(Event.COMPLETE, onComplete)
            datazip1.addEventListener(ProgressEvent.PROGRESS, onProgress1)

            var datazip2 = new URLLoader(new URLRequest("data2.zip"));
            datazip2.dataFormat = URLLoaderDataFormat.BINARY;
            datazip2.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError)
            datazip2.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError)
            datazip2.addEventListener(IOErrorEvent.IO_ERROR, onError)
            datazip2.addEventListener(Event.COMPLETE, onComplete)
            datazip2.addEventListener(ProgressEvent.PROGRESS, onProgress2)

            var datazip3 = new URLLoader(new URLRequest("data3.zip"));
            datazip3.dataFormat = URLLoaderDataFormat.BINARY;
            datazip3.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError)
            datazip3.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError)
            datazip3.addEventListener(IOErrorEvent.IO_ERROR, onError)
            datazip3.addEventListener(Event.COMPLETE, onComplete)
            datazip3.addEventListener(ProgressEvent.PROGRESS, onProgress3)

            loader = new Loader()
            var urlrq = new URLRequest("neverball.swf")
            loader.contentLoaderInfo.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onError)
            loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError)
            loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onError)
            loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onEngineComplete);
            loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onEngineProgress);
            var context = new LoaderContext();
            childDomain = new ApplicationDomain();
            context.applicationDomain = childDomain;
            loader.load(urlrq, context)
		}

        private var p1:int,p2:int,p3:int,p4:int;

        private function onProgress1(e:ProgressEvent):void {
            p1 = uint(e.bytesLoaded / e.bytesTotal * 100)
            setStatus("Downloading " + uint((p1+p2+p3+p4) / 4) + "%")
        }

        private function onProgress2(e:ProgressEvent):void {
            p2 = uint(e.bytesLoaded / e.bytesTotal * 100)
            setStatus("Downloading " + uint((p1+p2+p3+p4) / 4) + "%")
        }

        private function onProgress3(e:ProgressEvent):void {
            p3 = uint(e.bytesLoaded / e.bytesTotal * 100)
            setStatus("Downloading " + uint((p1+p2+p3+p4) / 4) + "%")
        }

        private function onComplete(e:Event):void {
            datazips.push(e.target.data);
            if(datazips.length == 3)
                this.addEventListener(Event.ENTER_FRAME, enterFrame);
        }

        private function startLoad():void {
            try {
            } catch (e:Error) {
                setStatus("Threw error " + e)
                fail = true
            }
        }

        private function onEngineProgress(e:ProgressEvent):void {
            p4 = uint(e.bytesLoaded / e.bytesTotal * 100)
            setStatus("Downloading " + uint((p1+p2+p3+p4) / 4) + "%")
        }

        private function onEngineComplete(e:Event):void {
            engineLoaded = true;
        }

        private function onError(e:Event):void
        {
            setStatus("Error:" + e)
            fail = true
        }

        private function enterFrame(e:Event):void {
            if(!engineLoaded)
                return;

            if(datazips.length > 0) {
                var f = childDomain.getDefinition("com.adobe.alchemy.addVFSZip");
                f(datazips.pop());
                return;
            }

            this.removeEventListener(Event.ENTER_FRAME, enterFrame);
            removeChild(progress)
            stage.addChild(loader)
        }
	}
}
