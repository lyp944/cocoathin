require 'singleton'
require 'pathname'

module Cocoathin
  class Selectorfinder

    include Singleton

    def find_unused_sel(path, prefix)
      check_file_type(path)
      all_sel_list = find_all_sel(path)
      used_sel_list = find_ref_sel(path)

      unused_sel = []

      all_sel_list.each do |sel, class_and_sels|
        unless used_sel_list.include?(sel)
          unused_sel += class_and_sels
        end
      end

      if prefix
        unused_sel.select! do |classname_selector|
          current_prefix = classname_selector.byteslice(2, prefix.length)
          current_prefix == prefix
        end
      end

      unused_sel
    end

    def find_all_sel(path)
      apple_protocols = [
          'tableView:canEditRowAtIndexPath:',
          'commitEditingStyle:forRowAtIndexPath:',
          'tableView:viewForHeaderInSection:',
          'tableView:cellForRowAtIndexPath:',
          'tableView:canPerformAction:forRowAtIndexPath:withSender:',
          'tableView:performAction:forRowAtIndexPath:withSender:',
          'tableView:accessoryButtonTappedForRowWithIndexPath:',
          'tableView:willDisplayCell:forRowAtIndexPath:',
          'tableView:commitEditingStyle:forRowAtIndexPath:',
          'tableView:didEndDisplayingCell:forRowAtIndexPath:',
          'tableView:didEndDisplayingHeaderView:forSection:',
          'tableView:heightForFooterInSection:',
          'tableView:shouldHighlightRowAtIndexPath:',
          'tableView:shouldShowMenuForRowAtIndexPath:',
          'tableView:viewForFooterInSection:',
          'tableView:willDisplayHeaderView:forSection:',
          'tableView:willSelectRowAtIndexPath:',
          'willMoveToSuperview:',
          'scrollViewDidEndScrollingAnimation:',
          'scrollViewDidZoom',
          'scrollViewWillEndDragging:withVelocity:targetContentOffset:',
          'searchBarTextDidEndEditing:',
          'searchBar:selectedScopeButtonIndexDidChange:',
          'shouldInvalidateLayoutForBoundsChange:',
          'textFieldShouldReturn:',
          'numberOfSectionsInTableView:',
          'actionSheet:willDismissWithButtonIndex:',
          'gestureRecognizer:shouldReceiveTouch:',
          'gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:',
          'gestureRecognizer:shouldReceiveTouch:',
          'imagePickerController:didFinishPickingMediaWithInfo:',
          'imagePickerControllerDidCancel:',
          'animateTransition:',
          'animationControllerForDismissedController:',
          'animationControllerForPresentedController:presentingController:sourceController:',
          'navigationController:animationControllerForOperation:fromViewController:toViewController:',
          'navigationController:interactionControllerForAnimationController:',
          'alertView:didDismissWithButtonIndex:',
          'URLSession:didBecomeInvalidWithError:',
          'setDownloadTaskDidResumeBlock:',
          'tabBarController:didSelectViewController:',
          'tabBarController:shouldSelectViewController:',
          'applicationDidReceiveMemoryWarning:',
          'application:didRegisterForRemoteNotificationsWithDeviceToken:',
          'application:didFailToRegisterForRemoteNotificationsWithError:',
          'application:didReceiveRemoteNotification:fetchCompletionHandler:',
          'application:didRegisterUserNotificationSettings:',
          'application:performActionForShortcutItem:completionHandler:',
          'application:continueUserActivity:restorationHandler:',

          'application:configurationForConnectingSceneSession:options:',
          'application:didDiscardSceneSessions:',
          'application:didFinishLaunchingWithOptions:',
          'scene:willConnectToSession:options:',
          'sceneDidBecomeActive:',
          'sceneDidDisconnect:',
          'sceneDidEnterBackground:',
          'sceneWillEnterForeground:',
          'sceneWillResignActive:',
          'window',
      ].freeze

      # imp -[class sel]

      sub_patten = /[+|-]\[.+\s(.+)\]/
      patten = /\s*imp\s*0x\w*\s*(#{sub_patten})/
      sel_set_patten = /set[A-Z].*:$/
      sel_get_patten = /is[A-Z].*/

      output = `/usr/bin/otool -oV #{path}`

      imp = {}

      output.each_line do |line|
        patten.match(line) do |m|
          sub = sub_patten.match(m[0]) do |subm|

            class_and_sel = subm[0]
            sel = subm[1]

            next if sel.start_with?('.')
            next if apple_protocols.include?(sel)
            next if sel_set_patten.match?(sel)
            next if sel_get_patten.match?(sel)

            if imp.has_key?(sel)
              imp[sel] << class_and_sel
            else
              imp[sel] = [class_and_sel]
            end
          end
        end
      end

      imp.sort
    end

    def find_ref_sel(path)
      patten = /__TEXT:__objc_methname:(.+)/
      output = `/usr/bin/otool -v -s __DATA __objc_selrefs #{path}`

      sels = []
      output.each_line do |line|
        patten.match(line) do |m|
          sels << m[1]
        end
      end

      sels
    end

    def check_file_type(path)
      pathname = Pathname.new(path)
      # unless pathname.exist?
      #   raise "#{path} not exit!"
      # end

      cmd = "/usr/bin/file -b #{path}"
      output = `#{cmd}`

      unless output.include?('Mach-O')
        raise 'input file not mach-o file type'
      end

      pathname
    end
  end
end
