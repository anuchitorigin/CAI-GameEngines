//################################# INCLUDE #################################
//---- System Modules ----
// import crypto from 'crypto';

//---- Application Modules ----
import K from './constant';
import dbconnect from './db_data';
import { xString, xNumber, isData, incident } from './originutil';

//################################# DECLARATION #################################
const THIS_FILENAME = 'dbfunc.ts';

//################################# FUNCTION #################################
async function add_shelf(
  shelfid: string, 
  shelfname: string,
  descr: string,
  store_id: number
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO shelfs
        (shelfid, shelfname, descr, store_id)
        VALUES
        (?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      shelfid, 
      shelfname, 
      descr, 
      store_id
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_shelf', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_goodservice(
  goodsid: string, 
  goodsname: string,
  descr: string, 
  goodstype_id: number,
  unitcost: number,
  minstockqty: number,
  maxstockqty: number,
  pictureid: string,
  remark: string
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO goodservices
        (goodsid, goodsname, descr, goodstype_id, unitcost, minstockqty, maxstockqty, pictureid, remark)
        VALUES
        (?,?,?,?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      goodsid,
      goodsname,
      descr,
      goodstype_id,
      unitcost,
      minstockqty,
      maxstockqty,
      pictureid,
      remark
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_goodservice', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_station(
  stationid: string, 
  stationname: string,
  descr: string
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO stations
        (stationid, stationname, descr)
        VALUES
        (?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      stationid,
      stationname,
      descr
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_station', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_vendor(
  vendorid: string, 
  vendorname: string,
  vendortype: string,
  contact: string, 
  address1: string,
  address2: string,
  telno: string,
  faxno: string,
  taxcode: string,
  remark: string
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO vendors
        (vendorid, vendorname, vendortype, contact, address1, address2, telno, faxno, taxcode, remark)
        VALUES
        (?,?,?,?,?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      vendorid, 
      vendorname, 
      vendortype,
      contact, 
      address1, 
      address2, 
      telno, 
      faxno, 
      taxcode, 
      remark
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_vendor', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_bom(
  bomid: string, 
  bomname: string,
  descr: string,
  goodservice_id: number, 
  quantity: number,
  manhour: number,
  remark: string
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO boms
        (bomid, bomname, descr, goodservice_id, quantity, manhour, remark)
        VALUES
        (?,?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      bomid, 
      bomname, 
      descr,
      goodservice_id, 
      quantity,
      manhour, 
      remark
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_bom', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_bomitem(
  bom_id: number,
  itemno: number,
  goodservice_id: number,
  quantity: number,
  remark: string
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO bomitems
        (bom_id, itemno, goodservice_id, quantity, remark)
        VALUES
        (?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      bom_id, 
      itemno, 
      goodservice_id,
      quantity, 
      remark
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_bomitem', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_recipe(
  recipeid: string, 
  recipename: string,
  descr: string, 
  bom_id: number,
  docid: string,
  docrevno: number,
  refid: string,
  writername: string,
  remark: string
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO recipes
        (recipeid, recipename, descr, bom_id, docid, docrevno, refid, writername, remark)
        VALUES
        (?,?,?,?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      recipeid, 
      recipename, 
      descr,
      bom_id, 
      docid, 
      docrevno, 
      refid, 
      writername, 
      remark
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_recipe', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_recipeitem(
  recipe_id: number,
  itemno: number,
  stepname: string,
  station_id: number,
  pictureid: string,
  contentid: string
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO recipeitems
        (recipe_id, itemno, stepname, station_id, pictureid, contentid)
        VALUES
        (?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      recipe_id, 
      itemno, 
      stepname,
      station_id, 
      pictureid, 
      contentid
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_recipeitem', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function get_sysvar(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, varid, varname, descr, varvalue
        FROM sysvars
        WHERE id = ?
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_sysvar', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_sysvars() {
  let records = [];
  try {
    const sql = `
      SELECT id, varid, varname, descr, varvalue
        FROM sysvars
        ORDER BY id;
    `;
    const result = await dbconnect.execute(sql, []);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_sysvars', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_stores() {
  let records = [];
  try {
    const sql = `
      SELECT id, storeid, storename, descr
        FROM stores
        ORDER BY id;
    `;
    const result = await dbconnect.execute(sql, []);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_stores', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_shelf(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, shelfid, shelfname, descr, store_id
        FROM shelfs
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_shelf', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_shelfs(
  shelfid: string,
  shelfname: string,
  descr: string,
  store_id: any,
  filter: any
) {
  const limit = xNumber(filter.limit);
  const page = xNumber(filter.page);
  const sort = xString(filter.sort);
  // Validation
  if ((limit <= 0) || (page <= 0)) {
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  let p = page - 1;
  if (p <= 0) { p = 0; }
  const offset = p * limit;
  let sortclause = "ASC";
  if (sort.toLowerCase() == 'desc') {
    sortclause = "DESC";
  }
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (shelfid) {
    whereclause += " AND shelfid LIKE ?";
    argumentarr.push('%'+shelfid.trim()+'%');
  }
  if (shelfname) {
    whereclause += " AND shelfname LIKE ?";
    argumentarr.push('%'+shelfname.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(store_id)) {
    whereclause += " AND store_id IN (0,?)";
    argumentarr.push(xNumber(store_id));
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, shelfid, shelfname, descr, store_id
        FROM shelfs
        ${whereclause}
        ORDER BY shelfid ${sortclause}
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_shelfs', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_goodstypes() {
  let records = [];
  try {
    const sql = `
      SELECT id, typeid, typename, descr
        FROM goodstypes
        ORDER BY id;
    `;
    const result = await dbconnect.execute(sql, []);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_goodstypes', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_goodservice(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, belocked, goodsid, goodsname, descr, goodstype_id
        , unitcost, minstockqty, maxstockqty, pictureid, remark
        FROM goodservices
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_goodservice', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_goodservices(
  goodsid: string, 
  goodsname: string,
  descr: string, 
  goodstype_id: any,
  unitcostfrom: any,
  unitcostto: any,
  remark: string,
  filter: any
) {
  const limit = xNumber(filter.limit);
  const page = xNumber(filter.page);
  const sort = xString(filter.sort);
  // Validation
  if ((limit <= 0) || (page <= 0)) {
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  let p = page - 1;
  if (p <= 0) { p = 0; }
  const offset = p * limit;
  let sortclause = "ASC";
  if (sort.toLowerCase() == 'desc') {
    sortclause = "DESC";
  }
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (goodsid) {
    whereclause += " AND goodsid LIKE ?";
    argumentarr.push('%'+goodsid.trim()+'%');
  }
  if (goodsname) {
    whereclause += " AND goodsname LIKE ?";
    argumentarr.push('%'+goodsname.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(goodstype_id)) {
    whereclause += " AND goodstype_id = ?";
    argumentarr.push(xNumber(goodstype_id));
  }
  if (isData(unitcostfrom)) {
    whereclause += " AND unitcost >= ?";
    argumentarr.push(xNumber(unitcostfrom));
  }
  if (isData(unitcostto)) {
    whereclause += " AND unitcost <= ?";
    argumentarr.push(xNumber(unitcostto));
  }
  if (remark) {
    whereclause += " AND remark LIKE ?";
    argumentarr.push('%'+remark.trim()+'%');
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, belocked, goodsid, goodsname, descr, goodstype_id
        , unitcost, minstockqty, maxstockqty, pictureid, remark
        FROM goodservices
        ${whereclause}
        ORDER BY goodsid ${sortclause}
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_goodservices', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_station(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, stationid, stationname, descr
        FROM stations
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_station', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_stations() {
  let records = [];
  try {
    const sql = `
      SELECT id, stationid, stationname, descr
        FROM stations
        ORDER BY stationid;
    `;
    const result = await dbconnect.execute(sql, []);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_stations', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_vendor(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, belocked, vendorid, vendorname, vendortype, contact
        , address1, address2, telno, faxno, taxcode, remark
        FROM vendors
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_vendor', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_vendors(
  belocked: any,
  vendorid: string,
  vendorname: string,
  vendortype: string,
  contact: string,
  address1: string,
  address2: string,
  telno: string,
  faxno: string,
  taxcode: string,
  remark: string,
  filter: any
) {
  const limit = xNumber(filter.limit);
  const page = xNumber(filter.page);
  const sort = xString(filter.sort);
  // Validation
  if ((limit <= 0) || (page <= 0)) {
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  let p = page - 1;
  if (p <= 0) { p = 0; }
  const offset = p * limit;
  let sortclause = "ASC";
  if (sort.toLowerCase() == 'desc') {
    sortclause = "DESC";
  }
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (isData(belocked)) {
    whereclause += " AND belocked = ?";
    argumentarr.push(xNumber(belocked));
  }
  if (vendorid) {
    whereclause += " AND vendorid LIKE ?";
    argumentarr.push('%'+vendorid.trim()+'%');
  }
  if (vendorname) {
    whereclause += " AND vendorname LIKE ?";
    argumentarr.push('%'+vendorname.trim()+'%');
  }
  if (vendortype) {
    whereclause += " AND vendortype LIKE ?";
    argumentarr.push('%'+vendortype.trim()+'%');
  }
  if (contact) {
    whereclause += " AND contact LIKE ?";
    argumentarr.push('%'+contact.trim()+'%');
  }
  if (address1) {
    whereclause += " AND address1 LIKE ?";
    argumentarr.push('%'+address1.trim()+'%');
  }
  if (address2) {
    whereclause += " AND address2 LIKE ?";
    argumentarr.push('%'+address2.trim()+'%');
  }
  if (telno) {
    whereclause += " AND telno LIKE ?";
    argumentarr.push('%'+telno.trim()+'%');
  }
  if (faxno) {
    whereclause += " AND faxno LIKE ?";
    argumentarr.push('%'+faxno.trim()+'%');
  }
  if (taxcode) {
    whereclause += " AND taxcode LIKE ?";
    argumentarr.push('%'+taxcode.trim()+'%');
  }
  if (remark) {
    whereclause += " AND remark LIKE ?";
    argumentarr.push('%'+remark.trim()+'%');
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, belocked, vendorid, vendorname, vendortype, contact
        , address1, address2, telno, faxno, taxcode, remark
        FROM vendors
        ${whereclause}
        ORDER BY vendorid ${sortclause}
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_vendors', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_bom(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, belocked
        , bomid, bomname, descr
        , goodservice_id, quantity
        , manhour, remark
        FROM boms
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_bom', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_boms(
  belocked: any,
  bomid: string, 
  bomname: string,
  descr: string,
  goodservice_id: any, 
  manhourfrom: any,
  manhourto: any,
  remark: string,
  filter: any
) {
  const limit = xNumber(filter.limit);
  const page = xNumber(filter.page);
  const sort = xString(filter.sort);
  // Validation
  if ((limit <= 0) || (page <= 0)) {
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  let p = page - 1;
  if (p <= 0) { p = 0; }
  const offset = p * limit;
  let sortclause = "ASC";
  if (sort.toLowerCase() == 'desc') {
    sortclause = "DESC";
  }
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (isData(belocked)) {
    whereclause += " AND belocked = ?";
    argumentarr.push(xNumber(belocked));
  }
  if (bomid) {
    whereclause += " AND bomid LIKE ?";
    argumentarr.push('%'+bomid.trim()+'%');
  }
  if (bomname) {
    whereclause += " AND bomname LIKE ?";
    argumentarr.push('%'+bomname.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(goodservice_id)) {
    whereclause += " AND goodservice_id = ?";
    argumentarr.push(xNumber(goodservice_id));
  }
  if (isData(manhourfrom)) {
    whereclause += " AND manhour >= ?";
    argumentarr.push(xNumber(manhourfrom));
  }
  if (isData(manhourto)) {
    whereclause += " AND manhour <= ?";
    argumentarr.push(xNumber(manhourto));
  }
  if (remark) {
    whereclause += " AND remark LIKE ?";
    argumentarr.push('%'+remark.trim()+'%');
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, belocked
        , bomid, bomname, descr
        , goodservice_id, quantity
        , manhour, remark
        FROM boms
        ${whereclause}
        ORDER BY bomid ${sortclause}
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_boms', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_bomitems(bom_id: number) {
  let records = [];
  try {
    const sql = `
      SELECT bi.id, bi.itemno, bi.goodservice_id
        , gs.goodsid, gs.goodsname, gs.goodstype_id, gs.pictureid
        , bi.quantity, bi.remark
        FROM bomitems bi
        LEFT JOIN goodservices gs ON gs.id = bi.goodservice_id
        WHERE bi.bom_id = ?
        ORDER BY bi.itemno;
    `;
    const result = await dbconnect.execute(sql, [
      bom_id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_bomitems', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_recipe(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at
        , recipeid, recipename, descr, bom_id
        , docid, docrevno, refid, writername, remark
        FROM recipes
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_recipe', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_recipes(
  recipeid: string, 
  recipename: string,
  descr: string, 
  bom_id: any,
  docid: string,
  docrevno: any,
  refid: string,
  writername: string,
  remark: string,
  filter: any
) {
  const limit = xNumber(filter.limit);
  const page = xNumber(filter.page);
  const sort = xString(filter.sort);
  // Validation
  if ((limit <= 0) || (page <= 0)) {
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  let p = page - 1;
  if (p <= 0) { p = 0; }
  const offset = p * limit;
  let sortclause = "ASC";
  if (sort.toLowerCase() == 'desc') {
    sortclause = "DESC";
  }
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (recipeid) {
    whereclause += " AND recipeid LIKE ?";
    argumentarr.push('%'+recipeid.trim()+'%');
  }
  if (recipename) {
    whereclause += " AND recipename LIKE ?";
    argumentarr.push('%'+recipename.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(bom_id)) {
    whereclause += " AND bom_id = ?";
    argumentarr.push(xNumber(bom_id));
  }
  if (docid) {
    whereclause += " AND docid LIKE ?";
    argumentarr.push('%'+docid.trim()+'%');
  }
  if (isData(docrevno)) {
    whereclause += " AND docrevno = ?";
    argumentarr.push(xNumber(docrevno));
  }
  if (refid) {
    whereclause += " AND refid LIKE ?";
    argumentarr.push('%'+refid.trim()+'%');
  }
  if (writername) {
    whereclause += " AND writername LIKE ?";
    argumentarr.push('%'+writername.trim()+'%');
  }
  if (remark) {
    whereclause += " AND remark LIKE ?";
    argumentarr.push('%'+remark.trim()+'%');
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at
        , recipeid, recipename, descr, bom_id
        , docid, docrevno, refid, writername, remark
        FROM recipes
        ${whereclause}
        ORDER BY recipeid ${sortclause}
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_recipes', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_recipeitem(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, recipe_id
        , itemno, stepname, station_id
        , pictureid, contentid
        FROM recipeitems
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_recipeitem', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_recipeitems(
  recipe_id: number,
  stepname: string,
  filter: any
) {
  const limit = xNumber(filter.limit);
  const page = xNumber(filter.page);
  const sort = xString(filter.sort);
  // Validation
  if ((limit <= 0) || (page <= 0)) {
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  let p = page - 1;
  if (p <= 0) { p = 0; }
  const offset = p * limit;
  let sortclause = "ASC";
  if (sort.toLowerCase() == 'desc') {
    sortclause = "DESC";
  }
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (isData(recipe_id)) {
    whereclause += " AND recipe_id = ?";
    argumentarr.push(xNumber(recipe_id));
  }
  if (stepname) {
    whereclause += " AND stepname LIKE ?";
    argumentarr.push('%'+stepname.trim()+'%');
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, recipe_id
        , itemno, stepname, station_id
        , pictureid, contentid
        FROM recipeitems
        ${whereclause}
        ORDER BY itemno ${sortclause}, id
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_recipeitems', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function update_sysvar(
  id: number,
  varname: string,
  descr: string, 
  varvalue: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE sysvars
        SET varname = ?
          , descr = ?
          , varvalue = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      varname, 
      descr, 
      varvalue, 
      id
    ]); // ResultSetHeader { affectedRows: 1, insertId: 0, warningStatus: 0, changedRows: 1 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_sysvar', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_shelf(
  id: number,
  shelfid: string, 
  shelfname: string,
  descr: string,
  store_id: number
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE shelfs
        SET shelfid = ?
          , shelfname = ?
          , descr = ?
          , store_id = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      shelfid, 
      shelfname, 
      descr, 
      store_id, 
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_shelf', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_goodservice(
  id: number,
  belocked: number,
  goodsid: string, 
  goodsname: string,
  descr: string, 
  goodstype_id: number,
  unitcost: number,
  minstockqty: number,
  maxstockqty: number,
  pictureid: string,
  remark: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE goodservices
        SET belocked = ?
          , goodsid = ?
          , goodsname = ?
          , descr = ?
          , goodstype_id = ?
          , unitcost = ?
          , minstockqty = ?
          , maxstockqty = ?
          , pictureid = ?
          , remark = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      belocked, 
      goodsid,
      goodsname,
      descr,
      goodstype_id,
      unitcost,
      minstockqty,
      maxstockqty,
      pictureid,
      remark, 
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_goodservice', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_station(
  id: number,
  stationid: string, 
  stationname: string,
  descr: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE stations
        SET stationid = ?
          , stationname = ?
          , descr = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      stationid,
      stationname,
      descr,
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_station', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_vendor(
  id: number,
  belocked: number,
  vendorid: string, 
  vendorname: string,
  vendortype: string,
  contact: string, 
  address1: string,
  address2: string,
  telno: string,
  faxno: string,
  taxcode: string,
  remark: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE vendors
        SET belocked = ?
          , vendorid = ?
          , vendorname = ?
          , vendortype = ?
          , contact = ?
          , address1 = ?
          , address2 = ?
          , telno = ?
          , faxno = ?
          , taxcode = ?
          , remark = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      belocked, 
      vendorid, 
      vendorname, 
      vendortype,
      contact, 
      address1, 
      address2, 
      telno, 
      faxno, 
      taxcode, 
      remark, 
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_vendor', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_bom(
  id: number,
  belocked: number,
  bomid: string, 
  bomname: string,
  descr: string,
  goodservice_id: number, 
  quantity: number,
  manhour: number,
  remark: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE boms
        SET belocked = ?
          , bomid = ?
          , bomname = ?
          , descr = ?
          , goodservice_id = ?
          , quantity = ?
          , manhour = ?
          , remark = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      belocked, 
      bomid, 
      bomname, 
      descr,
      goodservice_id, 
      quantity,
      manhour, 
      remark, 
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_bom', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_recipe(
  id: number,
  recipeid: string, 
  recipename: string,
  descr: string, 
  bom_id: number,
  docid: string,
  docrevno: number,
  refid: string,
  writername: string,
  remark: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE recipes
        SET recipeid = ?
          , recipename = ?
          , descr = ?
          , bom_id = ?
          , docid = ?
          , docrevno = ?
          , refid = ?
          , writername = ?
          , remark = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      recipeid, 
      recipename, 
      descr,
      bom_id, 
      docid, 
      docrevno, 
      refid, 
      writername, 
      remark, 
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_recipe', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_recipeitem(
  id: number,
  recipe_id: number,
  itemno: number,
  stepname: string,
  station_id: number,
  pictureid: string,
  contentid: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE recipeitems
        SET recipe_id = ?
          , itemno = ?
          , stepname = ?
          , station_id = ?
          , pictureid = ?
          , contentid = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      recipe_id, 
      itemno, 
      stepname,
      station_id, 
      pictureid, 
      contentid, 
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_recipeitem', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_shelf(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM shelfs
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_shelf', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_goodservice(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM goodservices
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_goodservice', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_station(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM stations
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_station', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_vendor(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM vendors
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_vendor', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_bom(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM boms
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_bom', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_bomitems(bom_id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM bomitems
        WHERE bom_id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      bom_id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_bomitems', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_recipe(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM recipes
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_recipe', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_recipeitem(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM recipeitems
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_recipeitem', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_recipeitems(recipe_id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM recipeitems
        WHERE recipe_id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      recipe_id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_recipeitems', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function count_shelfs(
  shelfid: string,
  shelfname: string,
  descr: string,
  store_id: any
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (shelfid) {
    whereclause += " AND shelfid LIKE ?";
    argumentarr.push('%'+shelfid.trim()+'%');
  }
  if (shelfname) {
    whereclause += " AND shelfname LIKE ?";
    argumentarr.push('%'+shelfname.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(store_id)) {
    whereclause += " AND store_id IN (0,?)";
    argumentarr.push(xNumber(store_id));
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM shelfs
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_shelfs', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

async function count_goodservices(
  goodsid: string, 
  goodsname: string,
  descr: string, 
  goodstype_id: any,
  unitcostfrom: any,
  unitcostto: any,
  remark: string
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (goodsid) {
    whereclause += " AND goodsid LIKE ?";
    argumentarr.push('%'+goodsid.trim()+'%');
  }
  if (goodsname) {
    whereclause += " AND goodsname LIKE ?";
    argumentarr.push('%'+goodsname.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (goodstype_id) {
    whereclause += " AND goodstype_id = ?";
    argumentarr.push(goodstype_id);
  }
  if (isData(unitcostfrom)) {
    whereclause += " AND unitcost >= ?";
    argumentarr.push(xNumber(unitcostfrom));
  }
  if (isData(unitcostto)) {
    whereclause += " AND unitcost <= ?";
    argumentarr.push(xNumber(unitcostto));
  }
  if (remark) {
    whereclause += " AND remark LIKE ?";
    argumentarr.push('%'+remark.trim()+'%');
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM goodservices
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_goodservices', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

async function count_vendors(
  belocked: any,
  vendorid: string,
  vendorname: string,
  vendortype: string,
  contact: string,
  address1: string,
  address2: string,
  telno: string,
  faxno: string,
  taxcode: string,
  remark: string
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (isData(belocked)) {
    whereclause += " AND belocked = ?";
    argumentarr.push(xNumber(belocked));
  }
  if (vendorid) {
    whereclause += " AND vendorid LIKE ?";
    argumentarr.push('%'+vendorid.trim()+'%');
  }
  if (vendorname) {
    whereclause += " AND vendorname LIKE ?";
    argumentarr.push('%'+vendorname.trim()+'%');
  }
  if (vendortype) {
    whereclause += " AND vendortype = ?";
    argumentarr.push(vendortype);
  }
  if (contact) {
    whereclause += " AND contact LIKE ?";
    argumentarr.push('%'+contact.trim()+'%');
  }
  if (address1) {
    whereclause += " AND address1 LIKE ?";
    argumentarr.push('%'+address1.trim()+'%');
  }
  if (address2) {
    whereclause += " AND address2 LIKE ?";
    argumentarr.push('%'+address2.trim()+'%');
  }
  if (telno) {
    whereclause += " AND telno LIKE ?";
    argumentarr.push('%'+telno.trim()+'%');
  }
  if (faxno) {
    whereclause += " AND faxno LIKE ?";
    argumentarr.push('%'+faxno.trim()+'%');
  }
  if (taxcode) {
    whereclause += " AND taxcode LIKE ?";
    argumentarr.push('%'+taxcode.trim()+'%');
  }
  if (remark) {
    whereclause += " AND remark LIKE ?";
    argumentarr.push('%'+remark.trim()+'%');
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM vendors
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_vendors', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

async function count_boms(
  belocked: any,
  bomid: string, 
  bomname: string,
  descr: string,
  goodservice_id: any, 
  manhourfrom: any,
  manhourto: any,
  remark: string
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (isData(belocked)) {
    whereclause += " AND belocked = ?";
    argumentarr.push(xNumber(belocked));
  }
  if (bomid) {
    whereclause += " AND bomid LIKE ?";
    argumentarr.push('%'+bomid.trim()+'%');
  }
  if (bomname) {
    whereclause += " AND bomname LIKE ?";
    argumentarr.push('%'+bomname.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(goodservice_id)) {
    whereclause += " AND goodservice_id = ?";
    argumentarr.push(xNumber(goodservice_id));
  }
  if (isData(manhourfrom)) {
    whereclause += " AND manhour >= ?";
    argumentarr.push(xNumber(manhourfrom));
  }
  if (isData(manhourto)) {
    whereclause += " AND manhour <= ?";
    argumentarr.push(xNumber(manhourto));
  }
  if (remark) {
    whereclause += " AND remark LIKE ?";
    argumentarr.push('%'+remark.trim()+'%');
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM boms
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_boms', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

async function count_recipes(
  recipeid: string, 
  recipename: string,
  descr: string, 
  bom_id: any,
  docid: string,
  docrevno: any,
  refid: string,
  writername: string,
  remark: string
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (recipeid) {
    whereclause += " AND recipeid LIKE ?";
    argumentarr.push('%'+recipeid.trim()+'%');
  }
  if (recipename) {
    whereclause += " AND recipename LIKE ?";
    argumentarr.push('%'+recipename.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(bom_id)) {
    whereclause += " AND bom_id = ?";
    argumentarr.push(xNumber(bom_id));
  }
  if (docid) {
    whereclause += " AND docid LIKE ?";
    argumentarr.push('%'+docid.trim()+'%');
  }
  if (isData(docrevno)) {
    whereclause += " AND docrevno = ?";
    argumentarr.push(xNumber(docrevno));
  }
  if (refid) {
    whereclause += " AND refid LIKE ?";
    argumentarr.push('%'+refid.trim()+'%');
  }
  if (writername) {
    whereclause += " AND writername LIKE ?";
    argumentarr.push('%'+writername.trim()+'%');
  }
  if (remark) {
    whereclause += " AND remark LIKE ?";
    argumentarr.push('%'+remark.trim()+'%');
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM recipes
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_recipes', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

async function count_recipeitems(
  recipe_id: number,
  stepname: string
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (isData(recipe_id)) {
    whereclause += " AND recipe_id = ?";
    argumentarr.push(xNumber(recipe_id));
  }
  if (stepname) {
    whereclause += " AND stepname LIKE ?";
    argumentarr.push('%'+stepname.trim()+'%');
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM recipeitems
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_recipeitems', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

export {
  add_shelf,
  add_goodservice,
  add_station,
  add_vendor,
  add_bom,
  add_bomitem,
  add_recipe,
  add_recipeitem,
  get_sysvar,
  get_sysvars,
  get_stores,
  get_shelf,
  get_shelfs,
  get_goodstypes,
  get_goodservice,
  get_goodservices,
  get_station,
  get_stations,
  get_vendor,
  get_vendors,
  get_bom,
  get_boms,
  get_bomitems,
  get_recipe,
  get_recipes,
  get_recipeitem,
  get_recipeitems,
  update_sysvar,
  update_shelf,
  update_goodservice,
  update_station,
  update_vendor,
  update_bom,
  update_recipe,
  update_recipeitem,
  delete_shelf,
  delete_goodservice,
  delete_station,
  delete_vendor,
  delete_bom,
  delete_bomitems,
  delete_recipe,
  delete_recipeitem,
  delete_recipeitems,
  count_shelfs,
  count_goodservices,
  count_vendors,
  count_boms,
  count_recipes,
  count_recipeitems
}