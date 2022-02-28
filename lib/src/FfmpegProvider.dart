import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_recorder_ffmpeg/src/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class FfmpegProvider with ChangeNotifier {
  bool loading = false, isPlaying = false;

  Future mergeIntoVideo({
  required RenderType renderType
}) async {
    loading = true;
    notifyListeners();

    if (await Permission.storage.request().isGranted) {
      /// mp4 output
      String mp4Command= '-r 50 -i ${Constants.imagesPath} -vf scale=-1:720,fps=60 -pix_fmt yuv420p -y ${Constants
          .videoOutputPath}';
      /// 7mb gif output
      String gifCommand = '-r 50 -i ${Constants.imagesPath} -vf "scale=iw/2:ih/2" -y ${Constants
          .gifOutputPath}';

      await  FFmpegKit.execute(renderType == RenderType.gif ? gifCommand : mp4Command).then((rc) async{
        loading = false;
        notifyListeners();
        debugPrint('FFmpeg process exited with rc ==> ${await rc.getReturnCode()}');
        debugPrint('FFmpeg process exited with rc ==> ${rc.getCommand()}');
        var res = await rc.getReturnCode();

        if(res!.getValue() == 0){
          return true;
        } else if(res.getValue() == 1){
          return false;
        } else{
          return false;
        }
      });

      return false;
    } else if (await Permission.storage.isPermanentlyDenied) {
      loading = false;
      notifyListeners();
      openAppSettings();
      return false;
    }
  }
}