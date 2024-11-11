//################################# INCLUDE #################################
//---- System Modules ----
import express, { Router, Request, Response, NextFunction } from 'express';
import multer from 'multer';

//---- Application Modules ----
import K from '../engines/constant';
import env from '../engines/env';
import { K_log_incident } from '../engines/localconst';
import { xString, xNumber, sendObj } from '../engines/originutil';
import { verify_user } from '../engines/authutil';
import { add_bucket, get_bucket, delete_bucket } from '../engines/datautil';
import { add_log_user } from '../engines/logfunc';

//################################# DECLARATION #################################
const THIS_FILENAME = 'bucket.ts';

const A_MEGA = 1000000;

const storage = multer.memoryStorage()
const uploadfile = multer({ storage: storage });

//################################# FUNCTION #################################


//################################# ROUTE #################################
const router: Router = express.Router();

/* define the HOME route */
router.get('/', (req: Request, res: Response) => {
  res.send('This is -Bucket- API endpoint.');
});

/* v----- all routes below this middleware will use Bearer Token -----v */
router.use(async (req: Request, res: Response, next: NextFunction) => {
  await verify_user(req, res, next);
});

/* define the Create-One route */
router.post('/', uploadfile.single('imagedata'), async (req: Request, res: Response) => { 
  /**
   *  Request:- (form-data)
   *    {
   *      imagedata: file,
   *      filename: "myportrait.png"
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          bucketid: "IMG-16b12eef-7784-44ab-9700-de39211840dd"
   *        }
   *      ]
   *    }
   */
  const userid = xString(res.locals.userid);
  const file: any = req.file;
  if (!file) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  const filename = xString(req.body.filename);
  // const originalname = xString(file.originalname);
  const mimetype = xString(file.mimetype); 
  const size = xNumber(file.size); 
  const buffer = file.buffer;
  // if (!mimetype.startsWith('image')) {
  //   sendObj(1000, 'File is not an image', [], res);
  //   return;
  // }
  const image_size_limit = env.IMAGE_SIZE_MB * A_MEGA;
  if (size > image_size_limit) {
    sendObj(1001, 'File size is too big', [], res);
    return;
  }
  const bucketid = await add_bucket('', filename, mimetype, buffer);
  if ((bucketid == K.SYS_INTERNAL_PROCESS_ERROR) || (!bucketid)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    bucketid: bucketid,
  });  
  await add_log_user(userid, K_log_incident.BUCKET_ADD, logdetail);
  // -- Done
  sendObj(1, 'ok', [{ bucketid: bucketid }], res);
});

/* define the Read-One route */
router.get('/:uuid', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          bucketname: "my portrait",
   *          buckettype: "image/png",
   *          bucketdata: BLOB
   *        }
   *      ]
   *    }
   */
  const bucketid = xString(req.params.uuid);
  const buckets = await get_bucket(bucketid);
  if (buckets == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  if (buckets.length == 0) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', buckets, res);
});

/* define the Delete-One route */
router.delete('/:uuid', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const userid = xString(res.locals.userid);
  const bucketid = xString(req.params.uuid);
  if (!bucketid) {
    sendObj(4, 'Invalid request', [], res);
    return;
  }
  const affectedRows = await delete_bucket(bucketid);
  if (affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  if (!affectedRows) {
    sendObj(11, 'Unable to delete', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    bucketid: bucketid,
  }); 
  await add_log_user(userid, K_log_incident.BUCKET_DEL, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

export default router;