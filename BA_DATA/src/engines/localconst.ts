//################################# INCLUDE #################################


//################################# DECLARATION #################################
const K_SYSID = 'ba_data';

const K_log_incident = {
  // -- System Variables
  SYSVAR_EDIT: 'sysvar:edit',
  // -- User
  USER_EDIT: 'user:edit',
  USER_DEL: 'user:delete',
  // -- Bucket
  BUCKET_ADD: 'bucket:add',
  BUCKET_DEL: 'bucket:delete',
  // -- Content
  CONTENT_ADD: 'content:add',
  CONTENT_DEL: 'content:delete',
  // -- Module
  MODULE_ADD: 'module:add',
  MODULE_EDIT: 'module:edit',
  MODULE_DEL: 'module:delete',
  // -- Lesson
  LESSON_ADD: 'lesson:add',
  LESSON_EDIT: 'lesson:edit',
  LESSON_DEL: 'lesson:delete',
  // -- Exam
  EXAM_ADD: 'exam:add',
  EXAM_EDIT: 'exam:edit',
  EXAM_DEL: 'exam:delete',
  // -- Quiz
  QUIZ_ADD: 'quiz:add',
  QUIZ_EDIT: 'quiz:edit',
  QUIZ_DEL: 'quiz:delete',
}

export {
  K_SYSID,
  K_log_incident,
}