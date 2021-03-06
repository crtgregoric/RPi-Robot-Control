//
//  StreamHelper.m
//  RPi_Control
//
//  Created by Crt Gregoric on 10. 12. 14.
//  Copyright (c) 2014 crtgregoric. All rights reserved.
//

#import "StreamHelper.h"

#include <gst/gst.h>
#include <gst/video/video.h>

GST_DEBUG_CATEGORY_STATIC (debug_category);
#define GST_CAT_DEFAULT debug_category

@implementation StreamHelper {
    id ui_delegate;
    GstElement *pipeline;
    GstElement *video_sink;
    GMainContext *context;
    GMainLoop *main_loop;
    gboolean initialized;
    UIView *ui_video_view;
}

- (instancetype)initWithVideoFeedView:(UIView *)videoFeedView delegate:(id <StreamHelperDelegate>)delegate {

#ifdef MAC_SERVER
    return nil;
#else
    self = [super init];
    
    if (self) {
        self->ui_delegate = delegate;
        self->ui_video_view = videoFeedView;
        
        GST_DEBUG_CATEGORY_INIT (debug_category, "rpi-control", 0, "ios-rpi-control");
        gst_debug_set_threshold_for_name("rpi-control", GST_LEVEL_DEBUG);
        
        /* Start the bus monitoring task */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self app_function];
        });
    }
    
    return self;
#endif
}

-(void) dealloc
{
    [self stop];
}

-(void) play
{
    if(gst_element_set_state(pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE) {
        [self setUIMessage:"Failed to set pipeline to playing"];
    }
}

-(void) pause
{
    if(gst_element_set_state(pipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_FAILURE) {
        [self setUIMessage:"Failed to set pipeline to paused"];
    }
}

-(void) stop
{
    if (pipeline) {
        GST_DEBUG("Setting the pipeline to NULL");
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(pipeline);
        pipeline = NULL;
    }
}

/* Change the message on the UI through the UI delegate */
-(void)setUIMessage:(gchar*) message
{
//    NSString *string = [NSString stringWithUTF8String:message];
//    if(ui_delegate && [ui_delegate respondsToSelector:@selector(gstreamerSetUIMessage:)])
//    {
//        [ui_delegate gstreamerSetUIMessage:string];
//    }
}

- (void)notifyDelegate
{
    if ([ui_delegate respondsToSelector:@selector(streamerHelperDidStartDisplayingVideo:)]) {
        [ui_delegate streamerHelperDidStartDisplayingVideo:self];
    }
}

/* Retrieve errors from the bus and show them on the UI */
static void error_cb (GstBus *bus, GstMessage *msg, StreamHelper *self)
{
    GError *err;
    gchar *debug_info;
    gchar *message_string;
    
    gst_message_parse_error (msg, &err, &debug_info);
    message_string = g_strdup_printf ("Error received from element %s: %s", GST_OBJECT_NAME (msg->src), err->message);
    g_clear_error (&err);
    g_free (debug_info);
    [self setUIMessage:message_string];
    NSLog(@"%s", message_string);
    g_free (message_string);
    gst_element_set_state (self->pipeline, GST_STATE_NULL);
}

/* Notify UI about pipeline state changes */
static void state_changed_cb (GstBus *bus, GstMessage *msg, StreamHelper *self)
{
    GstState old_state, new_state, pending_state;
    gst_message_parse_state_changed (msg, &old_state, &new_state, &pending_state);
    /* Only pay attention to messages coming from the pipeline, not its children */
    if (GST_MESSAGE_SRC (msg) == GST_OBJECT (self->pipeline)) {
        const gchar *state = gst_element_state_get_name(new_state);
        gchar *message = g_strdup_printf("State changed to %s", state);
        
        if ((strcmp("PLAYING", state) == 0)) {
            [self notifyDelegate];
        }
        
        [self setUIMessage:message];
        g_free (message);
    }
}

/* Check if all conditions are met to report GStreamer as initialized.
 * These conditions will change depending on the application */
-(void) check_initialization_complete
{
    if (!initialized && main_loop) {
        GST_DEBUG ("Initialization complete, notifying application.");
//        if (ui_delegate && [ui_delegate respondsToSelector:@selector(gstreamerInitialized)])
//        {
//            [ui_delegate gstreamerInitialized];
//        }
        initialized = TRUE;
        
        [self play];
    }
}

/* Main method for the bus monitoring code */
-(void) app_function
{
    GstBus *bus;
    GSource *bus_source;
    GError *error = NULL;
    
    GST_DEBUG ("Creating pipeline");
    
    /* Create our own GLib Main Context and make it the default one */
    context = g_main_context_new ();
    g_main_context_push_thread_default(context);
    
    /* Build pipeline */
    pipeline = gst_parse_launch("tcpclientsrc name=src ! gdpdepay ! rtph264depay ! avdec_h264 ! videoconvert ! autovideosink sync=false", &error);
    if (error) {
        gchar *message = g_strdup_printf("Unable to build pipeline: %s", error->message);
        g_clear_error (&error);
        [self setUIMessage:message];
        NSLog(@"%s", message);
        g_free (message);
        return;
    }
    
    const char *host = kHostName.UTF8String;
    int port = (int)kStreamPortNumber;
    
    GstElement *src = gst_bin_get_by_name(GST_BIN(pipeline), "src");
    g_object_set(src, "host", host, "port", port, NULL);
    
    /* Set the pipeline to READY, so it can already accept a window handle */
    gst_element_set_state(pipeline, GST_STATE_READY);
    
    video_sink = gst_bin_get_by_interface(GST_BIN(pipeline), GST_TYPE_VIDEO_OVERLAY);
    if (!video_sink) {
        GST_ERROR ("Could not retrieve video sink");
        return;
    }
    gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(video_sink), (guintptr) (id) ui_video_view);
    
    /* Instruct the bus to emit signals for each received message, and connect to the interesting signals */
    bus = gst_element_get_bus (pipeline);
    bus_source = gst_bus_create_watch (bus);
    g_source_set_callback (bus_source, (GSourceFunc) gst_bus_async_signal_func, NULL, NULL);
    g_source_attach (bus_source, context);
    g_source_unref (bus_source);
    g_signal_connect (G_OBJECT (bus), "message::error", (GCallback)error_cb, (__bridge void *)self);
    g_signal_connect (G_OBJECT (bus), "message::state-changed", (GCallback)state_changed_cb, (__bridge void *)self);
    gst_object_unref (bus);
    
    /* Create a GLib Main Loop and set it to run */
    GST_DEBUG ("Entering main loop...");
    main_loop = g_main_loop_new (context, FALSE);
    [self check_initialization_complete];
    g_main_loop_run (main_loop);
    GST_DEBUG ("Exited main loop");
    g_main_loop_unref (main_loop);
    main_loop = NULL;
    
    /* Free resources */
    g_main_context_pop_thread_default(context);
    g_main_context_unref (context);
    gst_element_set_state (pipeline, GST_STATE_NULL);
    gst_object_unref (pipeline);
    
    return;
}

@end
