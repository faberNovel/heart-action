"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ModuleLoader = void 0;
const heart_core_1 = require("@fabernovel/heart-core");
const dotenv = require("dotenv");
const fs_1 = require("fs");
const MissingEnvironmentVariables_1 = require("../error/MissingEnvironmentVariables");
class ModuleLoader {
    constructor(debug = false) {
        // file that contains the list of required environment variables
        this.ENVIRONMENT_VARIABLE_MODEL = ".env.sample";
        this.PACKAGE_PREFIX = "@fabernovel/heart-";
        // assume that the root path is the one from where the script has been called
        // /!\ this approach does not follow symlink
        this.ROOT_PATH = process.cwd();
        this.debug = debug;
        console.debug(this.ROOT_PATH)
    }
    /**
     * Load the installed Heart modules:
     * 1. get the absolute paths of the installed Heart modules
     * 2. checks that no environment variables is missing
     * 3. loads the modules
     */
    load() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // retrieve the paths of @fabernovel/heart-* modules, except heart-cli and heart-core.
                // (Heart Core must not be installed as an npm package, but who knows ¯\_(ツ)_/¯)
                // paths are guessed according to the content of the package.json
                const modulesPaths = yield this.getPaths(new RegExp(`^${this.PACKAGE_PREFIX}(?!cli|core)`), `${this.ROOT_PATH}/package.json`);
                if (modulesPaths.length > 0) {
                    if (this.debug) {
                        console.log("Checking missing environment variables...");
                    }
                    // check if environment variables are missing,
                    // according to the .env.sample of the loaded modules
                    const missingEnvironmentVariables = this.loadEnvironmentVariables(modulesPaths);
                    if (missingEnvironmentVariables.length > 0) {
                        throw new MissingEnvironmentVariables_1.MissingEnvironmentVariables(missingEnvironmentVariables);
                    }
                }
                return this.loadModules(modulesPaths);
            }
            catch (error) {
                return Promise.reject(error);
            }
        });
    }
    /**
     * Load environment variables for the given loaded modules.
     *
     * @returns The environment variables names that are missing
     */
    loadEnvironmentVariables(modulesPaths) {
        const missingEnvironmentVariables = [];
        modulesPaths.forEach((modulePath) => {
            try {
                // load the .env.sample file from the module
                const requiredModuleDotenvVariables = Object.entries(dotenv.parse((0, fs_1.readFileSync)(modulePath + this.ENVIRONMENT_VARIABLE_MODEL, "utf8")));
                // set variables if
                // not yet registered in process.env
                // and having a default value in .env.sample file,
                requiredModuleDotenvVariables.forEach(([variableName, defaultValue]) => {
                    if (!process.env[variableName] && defaultValue.length !== 0) {
                        process.env[variableName] = defaultValue;
                    }
                });
                // get the environment variables names that are not registered in process.env
                const missingModuleEnvironmentVariables = requiredModuleDotenvVariables
                    .filter(([variableName]) => !process.env[variableName])
                    .map(([variableName]) => variableName);
                // add the missing module dotenv variables to the missing list
                missingEnvironmentVariables.push(...missingModuleEnvironmentVariables);
                // eslint-disable-next-line no-empty
            }
            catch (error) { }
        });
        return missingEnvironmentVariables;
    }
    /**
     * List the Heart modules root path, according to the modules defined in package.json that follows the given pattern.
     */
    getPaths(pattern, packageJsonPath) {
        return __awaiter(this, void 0, void 0, function* () {
            const packageJson = (yield Promise.resolve().then(() => require(packageJsonPath)).catch((error) => {
                if (this.debug) {
                    console.error(`package.json not found in ${this.ROOT_PATH}`);
                }
                throw error;
            }));
            // list the modules according to the given pattern
            // look into the 'dependencies' and 'devDependencies' keys
            const modulesNames = [];
            if (undefined !== packageJson["dependencies"]) {
                Object.keys(packageJson["dependencies"])
                    // add the module name to the list if it is not already there and matches the pattern
                    .filter((moduleName) => -1 === modulesNames.indexOf(moduleName) && pattern.test(moduleName))
                    .forEach((moduleName) => {
                    modulesNames.push(moduleName);
                });
            }
            if (undefined !== packageJson["devDependencies"]) {
                Object.keys(packageJson["devDependencies"])
                    // add the module name to the list if it is not already there and matches the pattern
                    .filter((moduleName) => -1 === modulesNames.indexOf(moduleName) && pattern.test(moduleName))
                    .forEach((moduleName) => {
                    modulesNames.push(moduleName);
                });
            }
            // list the absolute path of each modules
            const paths = modulesNames.map((moduleName) => `${this.ROOT_PATH}/node_modules/${moduleName}/`);
            if (this.debug) {
                paths.forEach((path) => console.log(`Looking for a module in ${path}`));
            }
            return paths;
        });
    }
    /**
     * Load a list of modules according to their path.
     */
    loadModules(modulesPaths) {
        return __awaiter(this, void 0, void 0, function* () {
            const promises = [];
            // do not use the .forEach() method here instead of the for() loop,
            // because the 'await' keyword will not be available.
            for (let i = 0; i < modulesPaths.length; i++) {
                const modulePath = modulesPaths[i];
                // read package.json file from the module to look for the module entry point
                // @see {@link https://docs.npmjs.com/files/package.json#main}
                try {
                    if (this.debug) {
                        console.log("Loading module %s...", modulePath);
                    }
                    const packageJson = (yield Promise.resolve().then(() => require(`${modulePath}package.json`)));
                    const pkg = (yield Promise.resolve().then(() => require(modulePath + packageJson.main)));
                    const module = pkg.default;
                    // only keep the modules that are compatible
                    if ((0, heart_core_1.isModuleAnalysis)(module) || (0, heart_core_1.isModuleListener)(module) || (0, heart_core_1.isModuleServer)(module)) {
                        // guess the module id from the package name: take the string after the characters "@fabernovel/heart-"
                        const matches = new RegExp(`^${this.PACKAGE_PREFIX}(.+)$`).exec(packageJson.name);
                        if (null === matches) {
                            console.error(`${packageJson.name} module not loaded because the name does not start with ${this.PACKAGE_PREFIX}.`);
                        }
                        else {
                            module.id = matches[1];
                            promises.push(module);
                        }
                    }
                }
                catch (error) {
                    console.error(error);
                }
            }
            return Promise.all(promises);
        });
    }
}
exports.ModuleLoader = ModuleLoader;
