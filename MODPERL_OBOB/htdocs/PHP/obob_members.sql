SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `obob_members` DEFAULT CHARACTER SET big5 ;
USE `obob_members` ;

-- -----------------------------------------------------
-- Table `obob_members`.`members`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `obob_members`.`members` (
  `member_id` INT(11) NOT NULL AUTO_INCREMENT ,
  `firstname` VARCHAR(50) NULL DEFAULT NULL,
  `lastname` VARCHAR(50) NULL DEFAULT NULL,
  `login` VARCHAR(50) NULL DEFAULT NULL,
  `email` VARCHAR(50) NULL DEFAULT NULL,
  `institution` VARCHAR(50) NULL DEFAULT NULL,
  `passwd` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`member_id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `obob_members`.`files`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `obob_members`.`files` (
  `idfiles` INT NOT NULL AUTO_INCREMENT ,
  `obob_member_id` INT(11) NOT NULL ,
  `obo_files` VARCHAR(50) NULL DEFAULT NULL ,
  PRIMARY KEY (`idfiles`) ,
  INDEX `fk_files_obob_members1` (`obob_member_id` ASC) ,
  CONSTRAINT `fk_files_obob_members1`
    FOREIGN KEY (`obob_member_id` )
    REFERENCES `obob_members`.`members` (`member_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
