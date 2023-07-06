import { All, Controller, Req, Res } from '@nestjs/common';
import { UploadService } from './upload.service';
import { Request, Response } from 'express';

@Controller('upload/*')
export class UploadController {
  constructor(private uploadService: UploadService) {}

  @All()
  async upload(@Req() req: Request, @Res() res: Response) {
    this.uploadService.uploadData(req, res);
  }
}
