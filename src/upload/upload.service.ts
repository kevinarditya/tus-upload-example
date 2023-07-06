import { Injectable } from '@nestjs/common';
import { Metadata, Server } from '@tus/server';
import { FileStore } from '@tus/file-store';
import { Request, Response } from 'express';

@Injectable()
export class UploadService {
  private readonly tusServer = new Server({
    path: '/app/img',
    datastore: new FileStore({ directory: '/app/img' }),
    namingFunction: (req: Request) => {
      // 'upload-metadata': 'filename YmVyYmVyYmVyLm00YQ==,filetype YXVkaW8veC1tNGE=',
      const { 'upload-metadata': uploadMetadata } = req.headers;
      const { filename } = Metadata.parse(uploadMetadata as string);
      return filename;
    },
  });
  uploadData(req: Request, res: Response) {
    return this.tusServer.handle(req, res);
  }
}
