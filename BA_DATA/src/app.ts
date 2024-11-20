/**
 *  Project:      CAI Game Engines
 *  Program:      Data and Report Backend
 *  Description:  For managing master data and report
 *  Version:      1.0
 *  Updated:      11 Nov 2024
 *  Programmer:   Mr. Anuchit Butkhunthong
 *  E-mail:       anuchit.b@origin55.com
 *  Update Information:
 *    * Version  1.0 (11 Nov 2024)
 *      - Prepare for V1
 */

//################################# INCLUDE #################################
//---- System Modules ----
import express, { Express, Request, Response, NextFunction } from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import http from 'http';
// import https from 'https';
// import fs from 'fs';

//---- Application Modules ----
/* Engines Group */
// import env from './engines/env';
import { getNowFormat } from './engines/originutil';

/* Routes Group */
import sysvar from './routes/sysvar';
import log_sys from './routes/log_sys';
import log_user from './routes/log_user';
import user from './routes/user';
import bucket from './routes/bucket';
import content from './routes/content';
import module from './routes/module';
import exam from './routes/exam';

//################################# DECLARATION #################################
const app: Express = express();
const appver: string = 'v1.0.20241120';
const port: number = 57102;
// const port: number = 80;
const corsOptions: cors.CorsOptions = {
  // -- Default --
  // origin: "*",
  // methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
  // preflightContinue: false,
  // optionsSuccessStatus: 204
  // -- Custom Configuration --
  // "origin": ["http://localhost:50000", "http://localhost:8100","http://qrsys.app", "http://neolix.app"],
};

// -- Loop Handlers --
// let H_Main_Loop: any = null;

// -- Handle Interval --
// const DB_DELAY = 30000; // 30 sec
// const HI_MAIN_LOOP = 3000; // 3 sec

//################################# ROUTE #################################
/* CORS policy (to get rid of "No 'Access-Control-Allow-Origin'") */
app.use(cors(corsOptions));
/* parse application/x-www-form-urlencoded */
app.use(bodyParser.urlencoded({ extended: false }));
/* parse application/json  */
app.use(bodyParser.json());
/* middleware that is specific to this router */
app.use((req: Request, res: Response, next: NextFunction) => {
  console.log('['+getNowFormat('th', 'Asia/Bangkok')+'] '+req.method+' '+req.originalUrl);
  next();
});

/* define the HOME route */
app.get('/', async (req: Request, res: Response) => {
  res.send(`This is BA_DATA API endpoint. (Build: ${appver})`);
});

// ---- API endpoints ----
/* Service Group */
app.use('/sysvar', sysvar);
app.use('/log_sys', log_sys);
app.use('/log_user', log_user);
app.use('/user', user);
app.use('/bucket', bucket);
app.use('/content', content);
app.use('/module', module);
app.use('/exam', exam);

/* Test Group */
// app.use('/test', test);

//################################# MAIN #################################
// -- Main Loop --
// const Main_Loop = async () => {
//   // ---- TEKLA ----
//   await handle_tekla_output();
//   // ---- Unitechnique ----
//   // await handle_unitechnique_output();
//   // await handle_unitechnique_input();
//   // ---- VCC ----
//   await handle_vcc_output();
//   await handle_vcc_input();
//   // ---- ORIGIN ----
//   await handle_origin1_input();
//   await handle_origin1_output();
//   await handle_origin2_input();
//   await handle_origin2_output();
//   // ---- ERP ----
//   await handle_erp1_input();
//   await handle_erp2_input();
//   H_Main_Loop = setTimeout(Main_Loop, HI_MAIN_LOOP);
// }
// H_Main_Loop = setTimeout(Main_Loop, DB_DELAY);

// -- Start Server ...
// Create a NodeJS HTTPS listener that points to the Express app.
// Use a callback function to tell when the server is created.
// To create self-signed SSL for development
// > openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365
// https
//   .createServer(
//     // Provide the private and public key to the server by reading each
// 		// file's content with the readFileSync() method.
//     {
//       key: fs.readFileSync('key.pem'),
//       cert: fs.readFileSync('cert.pem'),
//       passphrase: env.ssl_passphrase,
//     },
//     app
//   )
//   .listen(port, () => {
//   console.log(`<<< Welcome to BA_AUTH API backend. (Build: ${appver}) >>>`);
//   console.log('['+getNowFormat('th', 'Asia/Bangkok')+'] '+`Listening on port ${port}`);
// });
http
  .createServer(app)
  .listen(port, () => {
  console.log(`<<< Welcome to BA_DATA API backend. (Build: ${appver}) >>>`);
  console.log('['+getNowFormat('th', 'Asia/Bangkok')+'] '+`Listening on port ${port}`);
});

//################################# END OF MAIN PROGRAM #################################